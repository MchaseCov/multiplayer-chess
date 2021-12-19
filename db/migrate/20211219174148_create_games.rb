class CreateGames < ActiveRecord::Migration[7.0]
  def change
    create_table :games do |t|
      t.references :white_player, null: false, foreign_key: { to_table: :users }
      t.references :color_player, null: true, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
