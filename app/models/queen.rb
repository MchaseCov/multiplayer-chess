class Queen < Piece
  def valid_moves
    collect_valid_moves(moveset)
  end

  def moveset
    [[+1, +0, (8 - current_row)], # Y Upwards
     [-1, +0, (current_row - 1)], # Y Downwards
     [+0, +1, (8 - current_col)], # X Rightwards
     [+0, -1, (current_col - 1)], # X Leftwards
     [+1, +1, (8 - current_col)], # To Up & Right
     [-1, +1, (8 - current_col)], # To Down & Right
     [+1, -1, (current_col - 1)], # To Up & Left
     [-1, -1, (current_col - 1)]] # To Down & Left
  end
end
