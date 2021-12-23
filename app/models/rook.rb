class Rook < Piece
  def moveset
    [[+1, +0, (8 - current_row)], # Y Upwards
     [-1, +0, (current_row - 1)], # Y Downwards
     [+0, +1, (8 - current_col)], # X Rightwards
     [+0, -1, (current_col - 1)]] # X Leftwards
  end
end
