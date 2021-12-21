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
  # Callbacks
  # Scopes
  scope :white_team, -> { where('color = :boolean', boolean: false).includes(:game) }
  scope :color_team, -> { where('color = :boolean', boolean: true).includes(:game) }
  scope :taken_pieces, -> { where('taken = :boolean', boolean: true) }
  scope :untaken_pieces, -> { where('taken = :boolean', boolean: false) }
  scope :pawn, -> { where('type = :type', type: 'Pawn') }
  scope :rook, -> { where('type = :type', type: 'Rook') }
  scope :bishop, -> { where('type = :type', type: 'Bishop') }
  scope :knight, -> { where('type = :type', type: 'Knight') }
  scope :queen, -> { where('type = :type', type: 'Queen') }
  scope :king, -> { where('type = :type', type: 'King') }
  scope :not_king, -> { where.not('type = :type', type: 'King') }

  # Validations
  # Associations
  #===Games
  belongs_to :game
  #===Squares
  belongs_to :square, optional: true,
                      inverse_of: :piece
  #===Users
  belongs_to :user, optional: true,
                    inverse_of: :pieces
  # Methods
  #===Cannot seem to Alias due to valid_moves belonging to respective subclasses
  def attack_moves
    valid_moves
  end

  def report_line_of_sight
    @squares_to_block = []
    moveset.each do |row_movement, col_movement, amount_to_check|
      has_los = validate_square_king_version(row_movement, col_movement, amount_to_check)
      if has_los == true
        @squares_to_block << @squares_involved
        break
      end
    end
    @squares_to_block.flatten.each(&:set_square_as_urgent)
    @squares_to_block
  end

  #===Instance Variables

  private

  def enemy
    @enemy = color ? false : true
  end

  def current_row
    @current_row ||= square.row.to_i
  end

  def current_col
    @current_col ||= square.column.to_i
  end

  def game_squares
    @game_squares ||= game.squares
  end

  #===Moveset Methods

  #======Validation
  def collect_valid_moves(moveset)
    validated_moves = []
    moveset.each do |row_movement, col_movement, amount_to_check|
      validated_moves += validate_square(row_movement, col_movement, amount_to_check)
    end
    validated_moves
  end

  def validate_square(row_direction, col_direction, amount_to_check)
    valid = []
    row_count = col_count = 0
    amount_to_check.times do
      row_count += row_direction
      col_count += col_direction
      square = game_squares.find_by(row: (current_row + row_count), column: (current_col + col_count))
      break if square.nil? || square.piece&.color == color

      if square.piece.nil?
        valid << square unless @only_enemy
      elsif square.piece.color == enemy
        valid << square unless @no_enemy
        break
      end
    end
    valid
  end

  def dangerous_positions
    danger = []
    opposition = color ? game.white_pieces.untaken_pieces : game.color_pieces.untaken_pieces
    opposition.includes(:square).where.not(type: 'King').each do |piece|
      danger << piece.attack_moves
    end
    danger.flatten
  end

  def validate_square_king_version(row_direction, col_direction, amount_to_check)
    @squares_involved = [square]
    row_count = col_count = 0
    amount_to_check.times do
      row_count += row_direction
      col_count += col_direction
      square = game_squares.find_by(row: (current_row + row_count), column: (current_col + col_count))
      break if square.nil? || square.piece&.color == color

      if square.piece.nil?
        @squares_involved << square
      elsif square.piece.color == enemy
        @squares_involved << square
        break
      end
    end
    return true if @squares_involved.flatten.any? { |s| s.piece&.type == 'King' && s.piece&.color == enemy }

    false
  end
end
