# == Table Schema ==
#
# table name: games
#
# id                      :bigint       null: false, primary key
# white_player_id         :index        null:false, foreign key of 1 user
# color_player_id         :index                    foreign key of 1 user
# created_at              :datetime     null: false
# updated_at              :datetime     null: false
#
class Game < ApplicationRecord
  # Callbacks
  # Scopes
  # Validations
  # Associations
  validates_length_of :squares, maximum: 64
  #===Squares
  has_many :squares
  #===Users
  belongs_to :white_player, class_name: :User,
                            foreign_key: :white_player_id,
                            inverse_of: :white_games
  belongs_to :color_player, class_name: :User,
                            foreign_key: :color_player_id,
                            inverse_of: :color_games
  # Methods
end
