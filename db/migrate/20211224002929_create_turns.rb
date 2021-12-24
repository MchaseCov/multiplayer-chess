class CreateTurns < ActiveRecord::Migration[7.0]
  def change
    create_table :turns do |t|
      t.references :game, null: false, foreign_key: true
      t.boolean :capture, default: false

      t.timestamps
    end
  end
end
