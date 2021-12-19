# == Table Schema ==
#
# table name: scrollers
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
