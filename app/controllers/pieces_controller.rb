class PiecesController < ApplicationController
  #== All
  before_action :set_game_and_piece, :validate_ongoing_game, :validate_permission_to_move
  #=== Edit
  before_action :enforce_check, if: -> { @game.check }, only: %i[edit]
  before_action :stalemate, if: -> { @game.current_team_live_pieces.size == 1 }, only: %i[edit]
  before_action :fetch_valid_moves_for_piece, only: %i[edit]
  #=== Updating
  before_action :set_selected_square, :save_current_game_state,
                only: %i[update_pawn update_king update_knight update_rook update_bishop update_queen]
  before_action :process_turn,
                only: %i[update_knight update_rook update_bishop update_queen]

  def edit
    redirect_to @game if @squares.blank?
  end

  def update_pawn
    promote_pawn if @square.row.in? [1, 8]
    process_turn
  end

  def update_king
    if @piece.has_moved || @game.check
      process_turn
    elsif @square == @game.castle_square(@piece.square, 2)
      castle(@game.right_rook(@piece), 1)
    elsif @square == @game.castle_square(@piece.square, -2)
      castle(@game.left_rook(@piece), -1)
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

  def validate_ongoing_game
    redirect_to @game and return if @game.game_over
  end

  def validate_permission_to_move
    redirect_to @game and return unless @game.current_player == current_user && @piece.color == @game.current_color
  end

  def enforce_check(defender_color = @piece.color)
    king = @game.untaken_pieces.where(color: defender_color).king.first

    return if @game.team_can_intercept_checkmate(@game.team_of_piece(king).not_king.includes(:square, :game))
    return if king.escape_checkmate_moves

    @game.declare_player_as_winner(king.user == @game.white_player ? @game.color_player : @game.white_player)
  end

  def stalemate
    return if @piece.valid_moves.present?

    @game.declare_stalemate
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
    @piece_original_type = @piece.type
    @piece_original_square = @piece.square
    @original_target = @square
    @original_target_piece = @square.piece
  end

  #=======|SHARED VALIDATION|======
  def process_turn
    move_piece? ? proceed_with_turn : rollback_turn
  end

  def move_piece?
    @square.piece&.update_attribute(:taken, true)
    @square.piece = @piece
    @square.save
    !validate_king_safety_after_move
  end

  def validate_king_safety_after_move
    @king = @game.current_team_live_pieces.king.first
    @king.all_current_attacking_moves_of_team(@game.opposing_team_of_piece(@king)).any? { |s| s&.piece == @king }
  end

  def proceed_with_turn
    @piece.update_attribute(:has_moved, true)
    @game.squares.where(urgent: true).each(&:set_square_as_unurgent)
    update_turn
  end

  def update_turn
    determine_if_check
    @game.update_attribute(:turn, (@piece.color? ? false : true))
  end

  def rollback_turn
    @piece.type = @piece_original_type
    @piece_original_square.piece = @piece
    @original_target.piece = @original_target_piece
    @piece_original_square.save
    @original_target.save
    @original_target_piece&.update_attribute(:taken, false)
    redirect_to @game and return
  end

  def determine_if_check
    line_of_sight_path = @piece.collect_path_to(@piece.attack_moveset, @game.opposing_team_of_piece(@piece).king,
                                                @piece.square, &:possible_movements)
    if line_of_sight_path.present?
      line_of_sight_path.each(&:set_square_as_urgent)
      @game.update_attribute(:check, true)
      enforce_check(!@piece.color)
    elsif @game.check
      @game.update_attribute(:check, false)
    end
  end

  def castle(rook, direction)
    castle_square = @game.squares.find(@piece.square.id + direction)
    castle_square.piece = rook
    @square.piece = @piece
    rook.update_attribute(:has_moved, true)
    @piece.update_attribute(:has_moved, true)
    @game.update_attribute(:turn, (@piece.color? ? false : true))
    redirect_to @game and return
  end

  def promote_pawn
    option = params[:upgrade].to_i || 1
    @piece = @piece.promote(option)
  end
end
