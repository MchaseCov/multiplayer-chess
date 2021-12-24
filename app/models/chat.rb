# == Table Schema ==
#
# table name: chats
#
# id                      :bigint       null: false, primary key
# game_id                 :bigint        null: false, foreign key of 1 game indexed
# created_at              :datetime     null: false
# updated_at              :datetime     null: false
#
class Chat < ApplicationRecord
  belongs_to :game
  has_many :messages, dependent: :destroy
end
