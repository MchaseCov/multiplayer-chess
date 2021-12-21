class PiecesController < ApplicationController
  #== All
  before_action :set_game_and_piece
  before_action :validate_turn
  #=== Edit
  before_action :enforce_check, if: -> { @game.check }
  before_action :fetch_valid_moves_for_piece, only: %i[edit]
  #=== Updating
  before_action :set_selected_square,
                except: %i[edit]
  before_action :shared_update_assignments,
                only: %i[update_pawn update_knight update_rook update_bishop update_queen]
  after_action :update_turn, except: %i[edit]

  def edit
    redirect_to @game if @squares.blank?
  end

  def update_pawn
    return unless (@piece.square.row == 1 && @piece.color == true) || (@piece.square.row == 8 && @piece.color == false)

    @piece.update_attribute(:type, 'Queen')
  end

  def update_knight; end

  def update_rook; end

  def update_bishop; end

  def update_queen; end

  def update_king
    return shared_update_assignments if @piece.has_moved == true

    if @square == @game.squares.find_by(row: @piece.square.row, column: (@piece.square.column + 2))
      castle(@game.pieces.where(type: 'Rook', color: @piece.color).first, 1) # Right
    elsif @square == @game.squares.find_by(row: @piece.square.row, column: @piece.square.column - 2)
      castle(@game.pieces.where(type: 'Rook', color: @piece.color).last, -1) # Left
    else
      shared_update_assignments
    end
  end

  private

  def set_game_and_piece
    @piece = current_user.pieces.find(params[:piece_id] || params[:id])
    @game = @piece.game
  end

  def fetch_valid_moves_for_piece
    @squares = @piece.valid_moves
  end

  def set_selected_square
    @square = @game.squares.find(params[:square])
    return 401 if @square.piece&.color == @piece.color
  end

  def shared_update_assignments
    @square.piece&.update_attribute(:taken, true)
    @square.piece = @piece
    @piece.update_attribute(:has_moved, true)
  end

  def castle(rook, direction)
    castle_square = Square.find(@piece.square.id + direction)
    castle_square.piece = rook
    @square.piece = @piece
    rook.update_attribute(:has_moved, true)
    @piece.update_attribute(:has_moved, true)
  end

  def validate_turn
    redirect_to @game and return if @game.game_over

    if @game.turn
      redirect_to @game unless current_user == @game.color_player && @piece.color
    else
      redirect_to @game unless current_user == @game.white_player && !@piece.color
    end
  end

  def update_turn
    @game.update_attribute(:check, false) if @game.check
    @piece.valid_moves.each do |move|
      @game.update_attribute(:check, true) if move.piece&.type == 'King'
    end

    @game.update_attribute(:turn, (@piece.color? ? false : true))
  end

  def enforce_check
    redirect_to @game unless @piece.type == 'King'
    declare_winner unless @piece.valid_moves.present?
  end

  def declare_winner
    @game.update_attribute(:game_over, true)
    @game.update_attribute(:winner, (@game.turn ? @game.white_player : @game.color_player))
  end
end
