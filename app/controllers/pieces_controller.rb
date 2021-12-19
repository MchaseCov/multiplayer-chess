class PiecesController < ApplicationController
  def edit
    @piece = Piece.find(params[:id])
    @squares = @piece.game.squares.board_order
  end

  def update
    @piece = Piece.find(params[:id])
    @square = @piece.game.squares.find(params[:square])
    if @square.piece
      @square.piece.taken = true
      @square.piece.save
    end
    @square.piece = @piece
    redirect_to @piece.game
  end
end
