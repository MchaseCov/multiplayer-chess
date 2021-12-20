class Pawn < Piece
  def valid_moves
    collect_valid_moves + collect_valid_attacks
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

  def attack_moveset
    @no_enemy = false
    @only_enemy = true
    if color
      [[-1, +1, 1], # To Down & Right
       [-1, -1, 1]] # To Down & Left
    else
      [[+1, +1, 1], # To Up & Right
       [+1, -1, 1]] # To Up & Left
    end
  end

  def collect_valid_attacks
    validated_moves = []
    attack_moveset.each do |row_movement, col_movement, amount_to_check|
      validated_moves += validate_square(row_movement, col_movement, amount_to_check)
    end
    validated_moves
  end
end
