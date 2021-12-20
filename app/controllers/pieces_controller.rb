class PiecesController < ApplicationController
  before_action :set_edit_variables, only: %i[edit]
  before_action :set_update_variables, :shared_update_assignments,
                only: %i[update_pawn update_knight update_rook update_bishop]
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

  private

  def set_edit_variables
    @piece = Piece.find(params[:id])
    @squares = @piece.valid_moves
    @game = @piece.game
  end

  def set_update_variables
    @piece = Piece.find(params[:piece_id]) # When adding user ownership be sure to change this to user.piece.find
    @square = @piece.game.squares.find(params[:square])
    return 401 if @square.piece&.color == @piece.color
  end

  def shared_update_assignments
    @square.piece&.update_attribute(:taken, true)
    @square.piece = @piece
    @piece.update_attribute(:has_moved, true)
  end
end
