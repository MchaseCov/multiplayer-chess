# == Table Schema ==
#
# table name: pieces
#
# id                      :bigint       null: false, primary key
# type                    :string       STI
# color                   :boolean
# taken                   :boolean      default: false
# has_moved               :boolean      default: false
# game_id                 :index        null:false, foreign key of game
# square_id               :index                    foreign key of square
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

  # Validations
  # Associations
  #===Games
  belongs_to :game, touch: true
  #===Squares
  belongs_to :square, optional: true,
                      inverse_of: :piece,
                      touch: true

  # Methods
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
    @game_squares ||= game.squares.includes(:piece)
  end

  #===Moveset Methods

  #======Validation
  def collect_valid_moves
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
    opposition = color ? game.white_pieces : game.color_pieces
    opposition.untaken_pieces.includes(:square).where.not(type: 'King').each do |piece|
      danger << piece.valid_moves
    end
    danger.flatten
  end
end
