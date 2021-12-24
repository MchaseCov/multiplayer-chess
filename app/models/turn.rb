# == Table Schema ==
#
# table name: turns
#
# id                      :bigint       null: false      primary key
# game_id                 :bigint       null: false      foreign key of game
# start_piece_id          :bigint       null: false      foreign key of piece
# end_piece_id            :bigint       null: true       foreign key of piece
# start_square_id         :bigint       null: false      foreign key of square
# end_square_id           :bigint       null: false      foreign key of square
# created_at              :datetime     null: false
# updated_at              :datetime     null: false
#
class Turn < ApplicationRecord
  # Associations
  belongs_to :game, counter_cache: true

  belongs_to :start_piece, class_name: :Piece,
                           foreign_key: :start_piece_id,
                           inverse_of: :moved_turns
  belongs_to :end_piece, class_name: :Piece,
                         foreign_key: :end_piece_id,
                         inverse_of: :captured_turn,
                         optional: true

  belongs_to :start_square, class_name: :Square,
                            foreign_key: :start_square_id,
                            inverse_of: :started_turns
  belongs_to :end_square, class_name: :Square,
                          foreign_key: :end_square_id,
                          inverse_of: :ended_turns
end
