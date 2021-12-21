class AddCheckmateToGames < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :check, :boolean, default: false
  end
end
