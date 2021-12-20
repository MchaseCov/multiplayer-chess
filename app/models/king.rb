class King < Piece
  def valid_moves
    collect_king_safe_moves
  end

  def moveset
    [[+1, +0, 1], # Y Upwards
     [-1, +0, 1], # Y Downwards
     [+0, +1, 1], # X Rightwards
     [+0, -1, 1], # X Leftwards
     [+1, +1, 1], # To Up & Right
     [-1, +1, 1], # To Down & Right
     [+1, -1, 1], # To Up & Left
     [-1, -1, 1]] # To Down & Left
  end

  def collect_king_safe_moves
    valid_moves = collect_valid_moves
    return valid_moves if valid_moves.empty?

    dangerous_positions.each do |position|
      valid_moves.delete(position)
    end
    valid_moves
  end
end
