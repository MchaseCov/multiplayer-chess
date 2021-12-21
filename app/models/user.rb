# == Table Schema ==
#
# table name: users
#
# id                      :bigint       null: false, primary key
# username                :string
# encrypted_password      :string       null: false
# created_at              :datetime     null: false
# updated_at              :datetime     null: false
#
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  # Callbacks
  # Scopes
  # Validations
  validates_presence_of :username
  validates_uniqueness_of :username
  # Associations
  #===Games
  has_many :white_games, class_name: :Game,
                         foreign_key: :white_player_id,
                         inverse_of: :white_player,
                         dependent: :destroy
  has_many :color_games, class_name: :Game,
                         foreign_key: :color_player_id,
                         inverse_of: :color_player,
                         dependent: :destroy
  has_many :won_games, class_name: :Game,
                       foreign_key: :winner_id,
                       inverse_of: :winner
  #===Pieces
  has_many :pieces, inverse_of: :user

  # Methods
  def email_required?
    false
  end

  def email_changed?
    false
  end

  def will_save_change_to_email?
    false
  end
end
