class King < Piece
  def valid_moves
    collect_valid_safe_king_moves
  end

  def collect_valid_safe_king_moves
    valid_moves = collect_valid_moves(moveset)
    return valid_moves if valid_moves.blank?

    if has_moved == false
      castle_options = castle_moves
      valid_moves += castle_options unless castle_options.blank?
    end

    filter_unsafe_moves(valid_moves)
  end

  def find_enemy_range
    danger = []
    game.opposing_team_live_pieces.includes(:square).each do |p|
      danger << p.attack_moves
    end
    danger.flatten
  end

  def filter_unsafe_moves(king_moves)
    find_enemy_range.each do |position|
      king_moves.delete(position)
    end
    more_squares_to_check.each do |position|
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

  def attack_moves
    collect_valid_moves(moveset)
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

  def escape_checkmate_moves
    valid_moves = collect_valid_moves(moveset).flatten
    more_squares_to_check.each do |position|
      valid_moves.delete(position)
    end
    game.squares.where(urgent: true).to_a.flatten.each do |position|
      valid_moves.delete(position)
    end
    valid_moves.present? ? true : false
  end

  def more_squares_to_check
    danger = []
    game.opposing_team_live_pieces.includes(:square).each do |p|
      danger << p.report_line_of_sight_of_friendly_piece
    end
    danger.flatten
  end
end
