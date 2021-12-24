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
  has_many :requested_drawn_games, class_name: :Game,
                                   foreign_key: :draw_requestor_id,
                                   inverse_of: :draw_requestor
  #===Pieces
  has_many :pieces, inverse_of: :user
  has_many :white_pieces,
           through: :white_games,
           source: :white_pieces,
           foreign_key: :user_id,
           inverse_of: :white_user
  has_many :color_pieces,
           through: :color_games,
           source: :color_pieces,
           foreign_key: :user_id,
           inverse_of: :color_user

  has_many :started_turns, through: :game,
                           source: :turns,
                           foreign_key: :start_square_id,
                           inverse_of: :start_square

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
