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
  has_one :piece
  #===Games
  belongs_to :game, validate: true
  # Methods
end
