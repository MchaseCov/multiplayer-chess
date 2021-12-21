class PiecesController < ApplicationController
  #== All
  before_action :set_game_and_piece
  before_action :validate_permission_to_move
  before_action :enforce_check, if: -> { @game.check }
  #=== Edit
  before_action :fetch_valid_moves_for_piece, only: %i[edit]
  #=== Updating
  before_action :set_selected_square, :save_current_game_state, :process_turn,
                only: %i[update_pawn update_king update_knight update_rook update_bishop update_queen]

  def edit
    redirect_to @game if @squares.blank?
  end

  def update_pawn
    puts 'process turn all complete now, back to pawn shit'
    unless (@piece.square.row == 1 && @piece.color == true) || (@piece.square.row == 8 && @piece.color == false)
      redirect_to @game and return
    end

    @piece.update_attribute(:type, 'Queen')
  end

  def update_king
    if @piece.has_moved == true
      process_turn
    elsif @square == @game.squares.find_by(row: @piece.square.row, column: (@piece.square.column + 2))
      castle(@game.pieces.where(type: 'Rook', color: @piece.color).first, 1) # Right
    elsif @square == @game.squares.find_by(row: @piece.square.row, column: @piece.square.column - 2)
      castle(@game.pieces.where(type: 'Rook', color: @piece.color).last, -1) # Left
    else
      process_turn
    end
  end

  def update_knight; end

  def update_rook; end

  def update_bishop; end

  def update_queen; end

  private

  #=======|BEFORE ACTIONS : ALL|=======
  def set_game_and_piece
    @piece = current_user.pieces.find(params[:piece_id] || params[:id])
    @game = @piece.game
  end

  def validate_permission_to_move
    redirect_to @game and return if @game.game_over

    redirect_to @game and return if @game.turn && !(current_user == @game.color_player && @piece.color)
    redirect_to @game and return if !@game.turn && !(current_user == @game.white_player && !@piece.color)
  end

  def enforce_check
    redirect_to @game unless @piece.type == 'King'
    @game.declare_winner unless @piece.valid_moves.present?
  end

  #=======|BEFORE ACTIONS : EDIT|=======
  def fetch_valid_moves_for_piece
    @squares = @piece.valid_moves
  end

  #=======|BEFORE ACTIONS : UPDATE|=======
  def set_selected_square
    @square = @game.squares.find(params[:square])
  end

  def save_current_game_state
    puts 'saving game state'
    @piece_original_square = @piece.square
    @original_target = @square
    @original_target_piece = @square.piece
  end

  #=======|SHARED VALIDATION|======
  def process_turn
    puts 'process_turn'
    move_piece? ? proceed_with_turn : rollback_turn
  end

  def move_piece?
    puts 'move piece?'
    @square.piece&.update_attribute(:taken, true)
    @square.piece = @piece
    @square.save
    !validate_king_safety_after_move? # return true unless king is in danger
  end

  def validate_king_safety_after_move?
    puts 'validate king safety after move?'
    @king = @game.pieces.where(type: 'King', color: @piece.color).first
    !!@king.king_is_in_sights # false if king safe, true if not safe
  end

  def proceed_with_turn
    puts 'proceed with turn'
    @piece.update_attribute(:has_moved, true)
    update_turn
  end

  def update_turn
    puts 'update turn'
    @game.update_attribute(:check, false) if @game.check
    @piece.valid_moves.each do |move|
      @game.update_attribute(:check, true) if move.piece&.type == 'King'
    end

    @game.update_attribute(:turn, (@piece.color? ? false : true))
  end

  def rollback_turn
    puts 'rollback turn'
    @piece_original_square.piece = @piece
    @original_target.piece = @original_target_piece
    @piece_original_square.save
    @original_target.save
    @original_target_piece&.update_attribute(:taken, false)
    redirect_to @game and return
  end

  #=======|IF KING IS CASTLE|=======
  def castle(rook, direction)
    castle_square = Square.find(@piece.square.id + direction)
    castle_square.piece = rook
    @square.piece = @piece
    rook.update_attribute(:has_moved, true)
    @piece.update_attribute(:has_moved, true)
  end
end
