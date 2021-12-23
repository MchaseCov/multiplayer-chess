class Pawn < Piece
  #=======================================|VALIDATE MOVE OPTIONS GIVEN TO USER|=======================================

  # Forward squares that are free + diagonal squares that are opponent held
  def valid_moves
    collect_valid_moves(moveset, &:empty_squares) + collect_valid_moves(attack_moveset, &:capturable_squares)
  end

  # Diagonal squares that are held OR empty. For calculating future boardstate for king safety
  def attack_moves
    collect_valid_moves(attack_moveset, &:possible_movements)
  end

  # Pawn exclusive BLOCK FILTER (See piece.rb for more info)
  # Collects only enemy held squares
  # INCLUSIONS: opponent
  # EXCLUSIONS: empty, ally
  # BREAKS: all (only once in any given direction)
  def capturable_squares(square)
    throw :stop unless square&.piece&.color == !color

    @valid << square
    throw :stop
  end

  # Team dependent moveset
  def moveset
    if color
      [[-1, +0, (has_moved ? 1 : 2)]] # Y Downwards, 1 or 2
    else
      [[+1, +0, (has_moved ? 1 : 2)]] # Y Upwards, 1 or 2
    end
  end

  # Team dependent moveset for diagonals
  def attack_moveset
    if color
      [[-1, +1, 1], # To Down & Right
       [-1, -1, 1]] # To Down & Left
    else
      [[+1, +1, 1], # To Up & Right
       [+1, -1, 1]] # To Up & Left
    end
  end

  def promote(promotion)
    case promotion
    when 2
      Knight.create(color: color, game: game, square: square, user: user, has_moved: true)
    when 3
      Rook.create(color: color, game: game, square: square, user: user, has_moved: true)
    when 4
      Bishop.create(color: color, game: game, square: square, user: user, has_moved: true)
    else
      Queen.create(color: color, game: game, square: square, user: user, has_moved: true)
    end
  end
end
