class Bishop < Piece
  def valid_moves
    valid_diagonal_moves
  end
end
