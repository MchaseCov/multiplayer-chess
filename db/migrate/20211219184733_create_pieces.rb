class CreatePieces < ActiveRecord::Migration[7.0]
  def change
    create_table :pieces do |t|
      t.string :type
      t.boolean :color
      t.boolean :taken, default: false
      t.boolean :has_moved, default: false
      t.references :game, null: false, foreign_key: true
      t.references :square, null: false, foreign_key: true

      t.timestamps
    end
  end
end
