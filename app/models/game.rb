class Game < ApplicationRecord
  belongs_to :white_player
  belongs_to :color_player
end
