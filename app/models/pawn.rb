class Pawn < Piece
  def valid_moves
    possible_forward_moves.or(possible_attack_moves)
  end

  def possible_forward_moves
    first_move = game_squares.where(row: (color ? current_row - 1 : current_row + 1), column: current_col)
                             .where(piece: { id: nil })

    return first_move if first_move.empty? || has_moved == true

    first_move.or(game_squares.where(row: (color ? current_row - 2 : current_row + 2), column: current_col)
                              .where(piece: { id: nil }))
  end

  # self note:
  # Can use this later for King logic by having a method such as Game.last.pieces.where(type: "Pawn", taken: false).each do |p| p.possible_attack_moves end (but like .white_pieces or something instead of where type is pawn)
  def possible_attack_moves
    row_direction = color ? current_row - 1 : current_row + 1
    game_squares.where.not(piece: { id: nil })
                .where(row: row_direction, column: [current_col + 1, current_col - 1])
                .where(piece: { color: enemy })
  end

  def enemy
    @enemy = color ? false : true
  end

  def current_row
    @current_row ||= square.row.to_i
  end

  def current_col
    @current_col ||= square.column.to_i
  end

  def game_squares
    @game_squares ||= game.squares.includes(:piece)
  end
end
