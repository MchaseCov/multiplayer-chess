class PiecesController < ApplicationController
  def edit
    @piece = Piece.find(params[:id])
    @squares = @piece.valid_moves
    redirect_to @piece.game if @squares.blank?
  end

  def update
    @piece = Piece.find(params[:id])
    @square = @piece.game.squares.find(params[:square])
    @square.piece&.update_attribute(:taken, true)
    @square.piece = @piece
    @piece.update_attribute(:has_moved, true)
    # Refactor this into somewhere, probably
    if @piece.type == 'Pawn' && (@piece.square.row == 1 && @piece.color == true) || (@piece.square.row == 8 && @piece.color == false)
      @piece.update_attribute(:type, 'Queen')
    end
    redirect_to @piece.game
  end
end
