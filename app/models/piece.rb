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
    (possible_y_moves(amount) + possible_x_moves(amount))
  end

  def possible_y_moves(amount)
    current_column_squares = game_squares.where(column: current_col)
    forward = unobstructed_moves(current_column_squares.where('row > ?', current_row).order(row: :asc).limit((amount)))
    backward = unobstructed_moves(current_column_squares.where('row < ?',
                                                               current_row).order(row: :desc).limit((amount)))
    (forward + backward)
  end

  def possible_x_moves(amount)
    current_row_squares = game_squares.where(row: current_row)
    right = unobstructed_moves(current_row_squares.where('squares.column > ?',
                                                         current_col).order(column: :asc).limit((amount)))
    left = unobstructed_moves(current_row_squares.where('squares.column < ?',
                                                        current_col).order(column: :desc).limit((amount)))
    (right + left)
  end

  def unobstructed_moves(direction)
    valid = []
    direction.each do |square|
      if square.piece.nil?
        valid << square
      elsif square.piece.color == enemy
        valid << square
        break
      elsif square.piece.color == color
        break
      end
    end
    valid
  end
end
