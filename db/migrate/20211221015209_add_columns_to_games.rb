class AddColumnsToGames < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :game_over, :boolean, default: false
    add_column :games, :turn, :boolean, default: false
    add_reference :games, :winner, null: true, foreign_key: { to_table: :users }
  end
end
