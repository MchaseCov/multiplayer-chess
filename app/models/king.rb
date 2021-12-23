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
    valid_moves = collect_valid_moves(moveset, &:possible_movements)
    return valid_moves if valid_moves.blank?

    valid_moves += castle_moves if has_moved == false && !castle_moves.blank? && !game.check

    filter_unsafe_moves(valid_moves)
  end

  #=======================================|CHECKS IF CAN CASTLE|========================================
  # Assigns rooks. If rooks haven't moved && the squares between are clear, castle is offered as an option
  def castle_moves
    right_rook = game.right_rook(self)
    left_rook = game.left_rook(self)
    return if left_rook.has_moved && right_rook.has_moved

    @castleable = []
    add_castle_option(collect_valid_moves([[0, -1, 3]], &:empty_squares), 3, -2) if left_rook.has_moved == false
    return @castleable unless right_rook.has_moved == false

    add_castle_option(collect_valid_moves([[0, 1, 2]], &:empty_squares), 2, 2)
    @castleable
  end

  # Adds castle squares to the GUI options
  def add_castle_option(tiles, size, distance)
    @castleable << game_squares.find_by(row: current_row, column: (current_col + distance)) if tiles.size == (size)
  end

  #=======================================|VALIDATE SAFETY OF KING MOVEMENT|====================================

  # FILTERED MOVES
  # Removes options that are dangerous from king's valid moveset.
  # If game is in check (meaning the king is in sights of an enemy), allows those pieces to "see through" the king
  # to calculate their full potential moveset, hiding future moves the king is currently blocking behind itself.
  def filter_unsafe_moves(valid_moves)
    valid_moves = remove_dangerous_moves(valid_moves)
    valid_moves = remove_full_los_of_checker(valid_moves) if game.check == true
    valid_moves
  end

  #========================================================================|FILTERS: REMOVE ANY UNSAFE SQUARES|

  # Input: Valid moves within range of the king
  # Output: Valid moves within range of the king, NOT in range of an enemy
  def remove_dangerous_moves(valid_moves)
    dangerous_moves = prepare_move_outcome_simulation(valid_moves)
    dangerous_moves.each do |position|
      valid_moves.delete(position)
    end
    valid_moves
  end

  # Input: (DURING CHECK) Valid moves within range of the king, NOT in range of an enemy
  # Output: Valid moves without allowing "self bodyblocking"
  def remove_full_los_of_checker(valid_moves)
    dangerous_moves = full_los_past_king(game.opposing_team_of_piece(self).includes(:square,
                                                                                    :game).where(square: { urgent: true }))
    dangerous_moves.each do |position|
      valid_moves.delete(position)
    end
    valid_moves
  end

  #========================================================================|COLLECTORS: PROVIDE SQUARES TO THE FILTERS|

  # Sets up the 1-8 possible moves for simulation to remove unsafe squares
  def prepare_move_outcome_simulation(valid_moves)
    @unsafe = []
    original_square = square
    valid_moves.each do |move|
      validate_outcome_of_king_on_square(move)
    end
    original_square.piece = self
    @unsafe.flatten.compact
  end

  # Simulates a king on input square. If that king is checked, then mark the square as unsafe.
  def validate_outcome_of_king_on_square(move)
    original_piece = move.piece
    move.piece = King.create(color: color, has_moved: has_moved, game: game, square: move)
    @unsafe << move if move.piece.king_is_in_sights.present?
    move.piece.destroy
    move.piece = original_piece
  end

  # Simulate the king with the movesets of other piece types. If the king can directly line to it,
  # then that square is unsafe for the king.
  # Example using the first collect_path_to:
  # If the king can spot a rook or queen in a straight line from the given position, then that means
  # the rook or queen is threatening them.
  def king_is_in_sights
    enemy_team = game.opposing_team_of_piece(self)
    danger_paths = []
    danger_paths << collect_path_to(straight_moveset, enemy_team.rook.or(enemy_team.queen),
                                    &:possible_movements)
    danger_paths << collect_path_to(diagonal_moveset, enemy_team.bishop.or(enemy_team.queen),
                                    &:possible_movements)
    danger_paths << collect_path_to(knight_moveset, enemy_team.knight,
                                    &:possible_movements)
    danger_paths << collect_path_to(pawn_attack_moveset, enemy_team.pawn,
                                    &:possible_movements)
    danger_paths.flatten.compact
  end

  # Input: (DURING CHECK) Enemy pieces that are on a "urgent square", meaning they are causing check
  # Output: Evaluates their moveset like normal EXCEPT ignoring the king. This allows pieces to "see past the king"
  # and returns those squares to be filtered out
  def full_los_past_king(pieces)
    dangerous_moves = []
    pieces.each do |piece|
      dangerous_moves << piece.collect_valid_moves(piece.attack_moveset, &:look_past_king)
    end
    dangerous_moves.flatten.compact
  end

  #=======================================|MOVESET STORAGE METHODS|====================================

  # King attack moves are the <= 8 squares immediately around the king, this is used for preventing 2
  # kings from walking into each other while not infinite looping between the two kings validation.
  def attack_moves
    collect_valid_moves(moveset, &:possible_movements)
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
