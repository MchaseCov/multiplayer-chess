class King < Piece
  def valid_moves
    collect_valid_safe_king_moves
  end

  def collect_valid_safe_king_moves
    valid_moves = collect_valid_moves(moveset)
    return valid_moves if valid_moves.empty?

    valid_moves += castle_moves if has_moved == false

    filter_unsafe_moves(valid_moves)
  end

  def filter_unsafe_moves(king_moves)
    dangerous_positions.each do |position|
      king_moves.delete(position)
    end
    king_moves
  end

  def castle_moves
    right_rook = game.pieces.where(type: 'Rook', color: color).first
    left_rook = game.pieces.where(type: 'Rook', color: color).last
    return if left_rook.has_moved && right_rook.has_moved

    @castleable = []
    @no_enemy = true
    add_castle_option(collect_valid_moves([[0, -1, 3]]), 3, -2) if left_rook.has_moved == false
    return @castleable unless right_rook.has_moved == false

    add_castle_option(collect_valid_moves([[0, 1, 2]]), 2, 2)
    @castleable
  end

  def add_castle_option(tiles, size, distance)
    @castleable << game_squares.find_by(row: current_row, column: (current_col + distance)) if tiles.size == (size)
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

  def king_is_in_sights
    @squares_to_block = []
    los_pieces = 0
    opposition = color ? game.white_pieces.untaken_pieces : game.color_pieces.untaken_pieces
    opposition.includes(:square).where.not(type: 'King').each do |inspected_piece|
      puts "inspecting piece #{inspected_piece.type}"
      path_to_king = inspected_piece.attack_moves
      next unless path_to_king.any? { |moveable_square| moveable_square.piece&.type == 'King' }

      los_pieces += 1
      @squares_to_block << path_to_king
      @squares_to_block << inspected_piece.square
    end
    puts "done with the king safety check, returning #{!los_pieces.zero?}"
    !los_pieces.zero?
    # if 0 piecs have los, then false; king is not in sights
  end
end
