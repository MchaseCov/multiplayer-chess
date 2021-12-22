class Pawn < Piece
  def valid_moves
    collect_valid_moves(moveset) + collect_valid_moves(attack_moveset)
  end

  def moveset
    @no_enemy = true
    @only_enemy = false
    if color
      [[-1, +0, (has_moved ? 1 : 2)]]
    else
      [[+1, +0, (has_moved ? 1 : 2)]]
    end
  end

  def attack_moveset(no_enemy = false, only_enemy = true)
    @no_enemy = no_enemy
    @only_enemy = only_enemy
    if color
      [[-1, +1, 1], # To Down & Right
       [-1, -1, 1]] # To Down & Left
    else
      [[+1, +1, 1], # To Up & Right
       [+1, -1, 1]] # To Up & Left
    end
  end

  def attack_moves
    collect_valid_moves(attack_moveset(true, false))
  end

  def promote(promotion)
    options = %w[Queen Knight Rook Bishop]
    choice = options[promotion] || 'Queen'
    update(type: choice)
  end
end
