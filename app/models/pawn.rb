class Pawn < Piece
  def valid_moves
    possible_forward_moves.or(possible_attack_moves)
  end

  def possible_forward_moves
    if color
      forward_range = [current_row - 1]
      forward_range << current_row - 2 if has_moved == false
    else
      forward_range = [current_row + 1]
      forward_range << current_row + 2 if has_moved == false
    end
    game_squares.where(piece: { id: nil })
                .where(row: forward_range, column: current_col)
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
