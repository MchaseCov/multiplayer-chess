class PiecesController < ApplicationController
  before_action :set_edit_variables, only: %i[edit]
  before_action :set_update_variables,
                only: %i[update_pawn update_knight update_rook update_bishop update_queen update_king]
  before_action :shared_update_assignments,
                only: %i[update_pawn update_knight update_rook update_bishop update_queen]
  def edit
    redirect_to @piece.game if @squares.blank?
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

    if @square == @piece.game.squares.find_by(row: @piece.square.row, column: (@piece.square.column + 2))
      castle(@piece.game.pieces.where(type: 'Rook', color: @piece.color).first, 1) # Right
    elsif @square == @piece.game.squares.find_by(row: @piece.square.row, column: @piece.square.column(-2))
      castle(@piece.game.pieces.where(type: 'Rook', color: @piece.color).last, -1) # Left
    else
      shared_update_assignments
    end
  end

  private

  def set_edit_variables
    @piece = Piece.find(params[:id])
    @squares = @piece.valid_moves
    @game = @piece.game
  end

  def set_update_variables
    @piece = current_user.pieces.find(params[:piece_id])
    @square = @piece.game.squares.find(params[:square])
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
end
