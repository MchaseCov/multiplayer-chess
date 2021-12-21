class Knight < Piece
  def valid_moves
    collect_valid_moves(moveset)
  end

  def moveset
    [[+2, +1, 1],
     [+1, +2, 1],
     [-1, +2, 1],
     [-2, +1, 1],
     [-2, -1, 1],
     [-2, -1, 1],
     [-1, -2, 1],
     [+1, -2, 1],
     [+2, -1, 1]]
  end
end
