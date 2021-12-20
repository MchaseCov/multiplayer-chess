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
  scope :white_team, -> { where('color = :boolean', boolean: false) }
  scope :color_team, -> { where('color = :boolean', boolean: true) }
  scope :taken_pieces, -> { where('taken = :boolean', boolean: true) }

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
  def valid_straight_moves(amount = 8)
  #======Diagonals
  #=========All Directions
  def valid_diagonal_moves(amount = 8)
    (valid_up_right(amount) + valid_down_right(amount) + valid_up_left(amount) + valid_down_left(amount))
  end

  #=========To Up & Right
  def valid_up_right(amount = (8 - current_col))
    validate_square(amount, 1, 1)
  end

  #=========To Up & Left
  def valid_up_left(amount = (current_col - 1))
    validate_square(amount, 1, -1)
  end

  #=========To Down & Right
  def valid_down_right(amount = (8 - current_col))
    validate_square(amount, -1, 1)
  end

  #=========To Down & Left
  def valid_down_left(amount = (current_col - 1))
    validate_square(amount, -1, -1)
  end

  #======Validation
  def validate_square(column_count, row_direction, col_direction)
    valid = []
    row_count = col_count = 0
    column_count.times do
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
end
