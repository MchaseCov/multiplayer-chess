class AddTurnsCountToGames < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :turns_count, :integer
  end
end
