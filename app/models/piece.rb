# == Table Schema ==
#
# table name: pieces
#
# id                      :bigint       null: false, primary key
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
  belongs_to :square, optional: true, inverse_of: :piece

  # Methods
end
