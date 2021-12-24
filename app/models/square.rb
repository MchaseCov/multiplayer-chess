# == Table Schema ==
#
# table name: squares
#
# id                      :bigint       null: false, primary key
# column                  :integer      indexed
# row                     :integer      indexed
# urgent                  :boolean      indexed     default: false
# game_id                 :index        null:false, foreign key of game
# created_at              :datetime     null: false
# updated_at              :datetime     null: false
#
class Square < ApplicationRecord
  # Callbacks
  # Scopes
  scope :must_defend, -> { where('urgent = :boolean', boolean: true) }

  # Validations
  validates :column, :row, presence: true, numericality: {
    only_integer: true,
    greater_than: 0,
    less_than: 9
  }

  # Associations
  #===Games
  belongs_to :game, validate: true
  #===Pieces
  has_one :piece, inverse_of: :square
  #===Turns
  has_many :started_turns, through: :game,
                           source: :turns,
                           foreign_key: :start_square_id,
                           inverse_of: :start_square
  has_many :ended_turns, through: :game,
                         source: :turns,
                         foreign_key: :end_piece_id,
                         inverse_of: :end_square
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

  def set_square_as_urgent
    update(urgent: true)
  end

  def set_square_as_unurgent
    update(urgent: false)
  end
end
