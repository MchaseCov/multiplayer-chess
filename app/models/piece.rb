# == Table Schema ==
#
# table name: pieces
#
# id                      :bigint       null: false      primary key
# type                    :string       STI              index
# color                   :boolean                       indexed
# taken                   :boolean      default: false   indexed
# has_moved               :boolean      default: false
# user_id                 :index                         foreign key of user
# game_id                 :index        null:false,      foreign key of game
# square_id               :index                         foreign key of square
# created_at              :datetime     null: false
# updated_at              :datetime     null: false
#

class Piece < ApplicationRecord
  # Associations
  belongs_to :game
  belongs_to :square, optional: true,
                      inverse_of: :piece
  belongs_to :user, optional: true,
                    inverse_of: :pieces

  #=======================================|PIECE METHODS|=======================================

  #===========================================|SCOPES|==========================================
  scope :white_team, -> { where('color = :boolean', boolean: false) }
  scope :color_team, -> { where('color = :boolean', boolean: true) }
  scope :taken_pieces, -> { where('taken = :boolean', boolean: true) }
  scope :untaken_pieces, -> { where('taken = :boolean', boolean: false) }
  scope :pawn, -> { where('type = :type', type: 'Pawn') }
  scope :rook, -> { where('type = :type', type: 'Rook') }
  scope :bishop, -> { where('type = :type', type: 'Bishop') }
  scope :knight, -> { where('type = :type', type: 'Knight') }
  scope :queen, -> { where('type = :type', type: 'Queen') }
  scope :king, -> { where('type = :type', type: 'King') }
  scope :not_king, -> { where.not('type = :type', type: 'King') }

  #=======================================|SIMPLE RETURNS|======================================
  # Alias cannot be used due to STI
  # Allows Pawn and King to specify a differing "attack style" than their normal moving style.
  # All other pieces refer to this "alias"
  def attack_moves
    valid_moves
  end

  def attack_moveset
    moveset
  end

  def enemy_king_of_piece?(piece)
    type == 'King' && color != piece.color
  end

  #=======================================|SQUARE GATHERING & VALIDATION|========================
  # Finds moves to return as options to select on the GUI.
  # NOTE: Pawn & King have unique "valid_moves", all other pieces refer to this.
  def valid_moves
    collect_valid_moves(moveset, &:possible_movements)
  end

  # Collects the squares involved for a piece to move from self to target piece(s).
  # movesets          # 2D array of moves to check. Each piece has a moveset collection saved for general use.
  # targets           # Array of pieces to filter against. Will save paths that have each piece in LoS.
  # inclusion = nil   # Extra squares to include that would not be filtered, such as piece's starting square.
  # &method_to_call   # Specify a block to declare what squares are valid. More info in BLOCK FILTERS section below.
  def collect_path_to(movesets, targets, inclusion = nil, &method_to_call)
    validated_moves = []
    movesets.each do |row_movement, col_movement, amount_to_check|
      path_to_evaluate = evaluate_moveset(row_movement, col_movement, amount_to_check, method_to_call, inclusion)
      validated_moves << path_to_evaluate if path_to_evaluate.any? { |s| s.piece.in? targets }
    end
    validated_moves.flatten.compact
  end

  # Collects all squares validated by &method_to_call. Does not track paths or relations between squares.
  # Variables are the same as collect_path_to, but without a target to relate to.
  def collect_valid_moves(movesets, inclusion = nil, &method_to_call)
    validated_moves = []
    movesets.each do |row_movement, col_movement, amount_to_check|
      validated_moves += evaluate_moveset(row_movement, col_movement, amount_to_check, method_to_call, inclusion)
    end
    validated_moves.compact
  end

  private

  # An "initialize" for each moveset, [i, i, i], passed by collect_valid_moves or collect_path_to.
  # Grabs squares in the row and column direction of the respective first two numbers.
  # Third number is amount of times to loop. BLOCK FILTERS break the loop early.
  def evaluate_moveset(row_direction, col_direction, amount_to_check, method_to_call, inclusion = nil)
    @valid = [inclusion]
    @row_direction = row_direction
    @col_direction = col_direction
    @row_count = @col_count = 0
    catch(:stop) do
      amount_to_check.times do
        validate_square_for_movement(method_to_call)
      end
    end
    @valid.compact
  end

  # Grabs the next appropriate square in the loop and plugs it into the user's chosen BLOCK FILTER
  def validate_square_for_movement(method_to_call)
    @row_count += @row_direction
    @col_count += @col_direction
    square_to_validate = game_squares.find_by(row: (current_row + @row_count), column: (current_col + @col_count))
    method_to_call.call(self, square_to_validate)
  end

  #=======================================|BLOCK FILTERS|=======================================
  # The following blocks are "options" to plug into the collect_path_to & collect_valid_moves methods.
  # Allows specific filtering such as only taking squares that are empty or squares that aren't a friendly piece.
  # Keeps the above methods DRY while allowing adjustments for specific scenarios!

  # Collects only "Standard Moves".
  # INCLUSIONS: empty, opponent
  # EXCLUSIONS: ally
  # BREAKS: invalid, ally, opponent
  def possible_movements(square)
    throw :stop if square.nil? || square.piece&.color == color

    if square.piece.nil?
      @valid << square
    elsif square.piece.color == !color
      @valid << square
      throw :stop
    end
  end

  # Collects only empty squares.
  # INCLUSIONS: empty
  # EXCLUSIONS: occupied
  # BREAKS: invalid, occupied
  def empty_squares(square)
    if square.present? && square&.piece.nil?
      @valid << square
    else
      throw :stop
    end
  end

  # Collects "theoretical range" of a piece, for use in king protection
  # Looks past the opposing king and includes allies to collect moves that are
  # unsafe for the king to move to, even if they are "safe" at the present time
  # INCLUSIONS: all until break
  # EXCLUSIONS:
  # BREAKS: invalid, occupied (unless occupying piece is opposing king)
  def look_past_king(square)
    throw :stop if square.nil?
    @valid << square
    throw :stop if square.piece.present? && (square.piece&.color == !color && square.piece&.type != 'King')
  end

  #=======================================|INSTANCE VARIABLES|=======================================
  # Neatly save instance variables for pieces to reuse without requery, tucked neatly away down here.
  # Should these be attr_accessors in their respective models?
  def current_row
    @current_row ||= square.row.to_i
  end

  def current_col
    @current_col ||= square.column.to_i
  end

  def game_squares
    @game_squares ||= game.squares
  end

  #=======================================|MOVESETS|=======================================
  # Movesets stored here are so they can be used by both their respective piece & for king safety checks.
  # Alias methods with STI seem unstable, therefore each piece simply has a moveset method that refers
  # to one or more of these options.
  # Pawn.rb and King.rb contain specialized movesets as well

  def straight_moveset
    [[+1, +0, (8 - current_row)], # Y Upwards
     [-1, +0, (current_row - 1)], # Y Downwards
     [+0, +1, (8 - current_col)], # X Rightwards
     [+0, -1, (current_col - 1)]] # X Leftwards
  end

  # To find if there is a Bishop or Queen looking at the King
  def diagonal_moveset
    [[+1, +1, (8 - current_col)], # To Up & Right
     [-1, +1, (8 - current_col)], # To Down & Right
     [+1, -1, (current_col - 1)], # To Up & Left
     [-1, -1, (current_col - 1)]] # To Down & Left
  end

  # To find if any of the 8 surrounding knight-squares are a knight
  def knight_moveset
    [[+2, +1, 1],
     [+1, +2, 1],
     [-1, +2, 1],
     [-2, +1, 1],
     [-2, -1, 1],
     [-2, -1, 1],
     [-1, -2, 1],
     [+1, -2, 1],
     [+2, -1, 1]]
  end

  # To find if kings top or bottom diags contain a pawn (respective to direciton)
  def pawn_attack_moveset
    if color
      [[-1, +1, 1], # To Down & Right
       [-1, -1, 1]] # To Down & Left
    else
      [[+1, +1, 1], # To Up & Right
       [+1, -1, 1]] # To Up & Left
    end
  end
end
