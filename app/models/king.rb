class King < Piece
  #=======================================|VALIDATE MOVE OPTIONS GIVEN TO USER|=======================================
  # Final collection after all validation
  def valid_moves
    collect_valid_safe_king_moves
  end

  # Prevents full querying if king physically can't move.
  # THEN adds castle moves if castle is possible
  # THEN filters out unsafe moves to return as the final collection
  def collect_valid_safe_king_moves
    valid_moves = collect_valid_moves(moveset)
    return valid_moves if valid_moves.blank?

    valid_moves += castle_moves if has_moved == false && !castle_moves.blank?

    filter_unsafe_moves(valid_moves)
  end

  #=======================================|CHECKS IF CAN CASTLE|========================================
  # Assigns rooks. If rooks haven't moved && the squares between are clear, castle is offered as an option
  def castle_moves
    right_rook = game.full_team_of_piece(self).rook.first
    left_rook = game.full_team_of_piece(self).rook.last
    return if left_rook.has_moved && right_rook.has_moved

    @castleable = []
    @no_enemy = true
    add_castle_option(collect_valid_moves([[0, -1, 3]]), 3, -2) if left_rook.has_moved == false
    return @castleable unless right_rook.has_moved == false

    add_castle_option(collect_valid_moves([[0, 1, 2]]), 2, 2)
    @castleable
  end

  # Filters the between-tiles for obstacles, which is why {@castleable << "square.id - 3"} is not used instead
  def add_castle_option(tiles, size, distance)
    @castleable << game_squares.find_by(row: current_row, column: (current_col + distance)) if tiles.size == (size)
  end

  #=======================================|VALIDATE SAFETY OF KING MOVEMENT|====================================

  #========================================================================|COLLECTIONS: FILTER CHAINS TO DIRECTLY CALL|
  # Move options (edit screen GUI)
  # Removes squares where the enemy can see, or could retaliate if the square is currently an enemy
  def filter_unsafe_moves(valid_moves)
    valid_moves = remove_retaliatable_squares(valid_moves)
    remove_all_opponent_attack_options(valid_moves)
  end

  # Escape check options (game-over verification)
  def escape_checkmate_moves
    valid_moves = collect_valid_moves(moveset).flatten
    valid_moves = remove_retaliatable_squares(valid_moves)
    valid_moves = remove_checking_piece_los_squares(valid_moves)
    valid_moves = remove_all_opponent_attack_options(valid_moves)
    valid_moves.present? ? true : false
  end

  #========================================================================|FILTERS: REMOVE ANY UNSAFE SQUARES|
  # If king is able to take a piece, makes sure that there is not a watching enemy that could retaliate
  # Filters for: Move GUI && Game-over verification
  def remove_retaliatable_squares(valid_moves)
    takeable_pieces = find_pieces_under_king_attack(valid_moves)
    find_squares_where_enemy_can_los(takeable_pieces).each do |position|
      valid_moves.delete(position)
    end
    valid_moves
  end

  # Removes squares where enemy can make a capture move
  # Filters for: Move GUI && Game-over verification
  def remove_all_opponent_attack_options(valid_moves)
    possible_attacking_moves_of_team(game.opposing_team_of_piece(self)).each do |position|
      # all_current_attacking_moves_of_team(game.opposing_team_of_piece(self)).each do |position|
      valid_moves.delete(position)
    end
    valid_moves
  end

  # If king is in check, they cannot escape by walking into the enemy's LoS
  # Filters for: Game-over verification
  def remove_checking_piece_los_squares(valid_moves)
    game.squares.where(urgent: true).to_a.flatten.each do |position|
      valid_moves.delete(position)
    end
    valid_moves
  end

  #========================================================================|COLLECTORS: PROVIDE SQUARES TO THE FILTERS|
  # Collect all attacking moves a team can currently make
  # Reports to: validate_king_safety_after_move in pieces_controller.rb
  def all_current_attacking_moves_of_team(team)
    all_valid_moves = []
    team.includes(:square).each do |p|
      all_valid_moves << p.attack_moves
    end
    all_valid_moves.flatten
  end

  # Collect all attacking moves a team could make INCLUDING friends
  # Reports to: remove_all_opponent_attack_options
  def possible_attacking_moves_of_team(team)
    dangerous_moves = []
    team.includes(:square).each do |p|
      dangerous_moves << p.report_line_of_sight_of_friendly_piece
    end
    dangerous_moves.flatten
  end

  # Collect squares that are valid for a king to move to & contain an enemy
  # Reports to: remove_retaliatable_squares
  def find_pieces_under_king_attack(valid_moves)
    pieces_under_king_attack = []
    valid_moves.each do |move|
      pieces_under_king_attack << move if move.piece&.color == !color
    end
    pieces_under_king_attack
  end

  # Collects squares where opponent can retaliate against the king if the king makes a capture
  # Reports to: remove_retaliatable_squares
  def find_squares_where_enemy_can_los(takeable_pieces)
    retaliating_enemies_lines_of_attack = []
    game.opposing_team_of_piece(self).not_king.includes(:square).each do |p|
      retaliating_enemies_lines_of_attack << p.report_line_of_sight_on_piece(takeable_pieces)
    end
    retaliating_enemies_lines_of_attack.flatten.compact
  end
  #=======================================|MOVESET STORAGE METHODS|====================================

  # King attack moves are the <= 8 squares immediately around the king, this is used for preventing 2
  # kings from walking into each other while not infinite looping between the two kings validation.
  def attack_moves
    collect_valid_moves(moveset)
  end

  # Moveset for king. Format: [Y-direction, X direction, amount of squares the piece can move in that direction.]
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
end

# DEPRECATED BUT PRESERVED FOR TESTING
# Removes squares where enemy has a los to king, but this should already be done by opponent attack options
#  def remove_enemy_los_squares(valid_moves)
#   find_squares_where_enemy_can_los(self).each do |position|
#    valid_moves.delete(position)
# end
# valid_moves
# end
