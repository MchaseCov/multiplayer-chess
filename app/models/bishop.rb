class Bishop < Piece
  def valid_moves
    collect_valid_moves
  end

  def moveset
    [[+1, +1, (8 - current_col)], # To Up & Right
     [-1, +1, (8 - current_col)], # To Down & Right
     [+1, -1, (current_col - 1)], # To Up & Left
     [-1, -1, (current_col - 1)]] # To Down & Left
  end
end
