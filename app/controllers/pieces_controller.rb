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

  def enforce_check(king = @game.team_of_piece(@piece).king.first)
    @valid_king_moves = king.valid_moves
    return if @valid_king_moves.present?
    return if @game.team_can_intercept_checkmate(@game.team_of_piece(king).not_king.includes(:square, :game))

    @game.declare_player_as_winner(king.user == @game.white_player ? @game.color_player : @game.white_player)
  end

  def stalemate
    return if @piece.valid_moves.present?

    @game.declare_stalemate
  end

  #=======|BEFORE ACTIONS : EDIT|=======
  def fetch_valid_moves_for_piece
    @squares =
      # If moving the king during checkmate, use the already stored moves for validation instead of repeat query
      if @game.check && @piece.type == 'King'
        @valid_king_moves
      else
        @piece.valid_moves
      end
  end

  #=======|BEFORE ACTIONS : UPDATE|=======
  def set_selected_square
    @square = @game.squares.find(params[:square])
  end

  # Saves game state for potential rollback if an illegal move is made
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
    king_safe?
  end

  def king_safe?
    king = @game.current_team_live_pieces.king.first
    king.king_is_in_sights.blank?
  end

  def proceed_with_turn
    @pawn&.destroy
    @piece.update_attribute(:has_moved, true)
    @game.squares.where(urgent: true).each(&:set_square_as_unurgent)
    update_turn
  end

  def update_turn
    determine_if_check
    @game.update_attribute(:turn, (@piece.color? ? false : true))
  end

  def rollback_turn
    @piece = @pawn if @pawn
    @upgraded_piece&.destroy
    @piece_original_square.piece = @piece
    @original_target.piece = @original_target_piece
    @piece_original_square.save
    @original_target.save
    @original_target_piece&.update_attribute(:taken, false)
    redirect_to @game and return
  end

  def determine_if_check
    @enemy_king = @game.opposing_team_of_piece(@piece).king.first
    line_of_sight_path = @enemy_king.king_is_in_sights

    if line_of_sight_path.present?
      line_of_sight_path.each(&:set_square_as_urgent)
      @enemy_king.square.set_square_as_urgent
      @game.update_attribute(:check, true)
      enforce_check(@enemy_king)
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

  # Assigns "backup variables" in case of rollback
  def promote_pawn
    @pawn = @piece
    @upgraded_piece = @piece.promote(params[:upgrade].to_i || 1)
    @piece = @upgraded_piece
  end
end
