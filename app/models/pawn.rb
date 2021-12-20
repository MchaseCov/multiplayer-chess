class Pawn < Piece
  def valid_moves
    possible_forward_moves + possible_attack_moves
  end

  def possible_forward_moves
    @no_enemy = true
    @only_enemy = false
    if color == true
      valid_down(has_moved ? 1 : 2)
    else
      valid_up(has_moved ? 1 : 2)
    end
  end

  def possible_attack_moves
    @no_enemy = false
    @only_enemy = true
    if color == true
      valid_down_right(1) + valid_down_left(1)
    else
      valid_up_right(1) + valid_up_left(1)
    end
  end
end
