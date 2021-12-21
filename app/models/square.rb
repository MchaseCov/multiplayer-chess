# == Table Schema ==
#
# table name: squares
#
# id                      :bigint       null: false, primary key
# column                  :index
# row                     :index
# game_id                 :index        null:false, foreign key of game
# created_at              :datetime     null: false
# updated_at              :datetime     null: false
#
class Square < ApplicationRecord
  # Callbacks
  # Scopes

  # Validations
  validates :column, :row, presence: true, numericality: {
    only_integer: true,
    greater_than: 0,
    less_than: 9
  }

  # Associations
  #===Pieces
  has_one :piece, inverse_of: :square
  #===Games
  belongs_to :game, validate: true
  # Methods
  def coordinate
    "(#{column},#{row})"
  end

  # Only for use in view, not for comparisons
  def visual_coordinate
    h = {}
    ('A'..'Z').each_with_index { |w, i| h[i + 1] = w }
    "(#{h[column]}#{row})"
  end

  def self.board_order
    order(row: :desc).order(column: :asc)
  end
end
