class Knight < Piece
  def valid_moves
    possible_forward_moves
  end

  def possible_forward_moves
    moveset = [[2, 1], [1, 2], [-1, 2], [-2, 1], [-2, -1], [-2, -1], [-1, -2], [1, -2], [2, -1]]
    range = moveset.map { |r, h| [r + current_row, h + current_col] }
    moves = []
    range.each do |r|
      moves << game_squares.where.not(piece: { color: color })
                           .or(game_squares.where(piece: { id: nil }))
                           .find_by(row: r[0], column: r[1])
    end
    moves
  end
end
