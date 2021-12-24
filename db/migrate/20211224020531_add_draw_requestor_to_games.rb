class AddDrawRequestorToGames < ActiveRecord::Migration[7.0]
  def change
    add_reference :games, :draw_requestor, null: true, foreign_key: { to_table: :users }
  end
end
