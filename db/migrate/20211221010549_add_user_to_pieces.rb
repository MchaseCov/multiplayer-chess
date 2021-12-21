class AddUserToPieces < ActiveRecord::Migration[7.0]
  def change
    add_reference :pieces, :user, null: true, foreign_key: true
  end
end
