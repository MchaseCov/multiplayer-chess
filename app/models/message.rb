# == Table Schema ==
#
# table name: messages
#
# id                      :bigint       null: false, primary key
# body                    :text
# author_id               :bigint       null: false, foreign key of author user
# chat_id                 :bigint       null: false, foreign key of chat
# created_at              :datetime     null: false
# updated_at              :datetime     null: false
#
class Message < ApplicationRecord
  after_create_commit do
    broadcast_append_later_to chat
  end

  belongs_to :chat
  belongs_to :author, class_name: :User,
                      foreign_key: :author_id,
                      inverse_of: :authored_messages
  has_one :game, through: :chat, source: :game
end
