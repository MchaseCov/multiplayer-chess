class CreateSquares < ActiveRecord::Migration[7.0]
  def change
    create_table :squares do |t|
      t.integer :row
      t.integer :column
      t.references :game, null: false, foreign_key: true

      t.timestamps
    end
  end
end
