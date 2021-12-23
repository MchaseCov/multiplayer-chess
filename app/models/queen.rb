class Queen < Piece
  def moveset
    straight_moveset + diagonal_moveset
  end
end
