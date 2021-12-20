class AddIndexesToTable < ActiveRecord::Migration[7.0]
  def change
    add_index :squares, :row
    add_index :squares, :column
    add_index :pieces, :color
    add_index :pieces, :taken
  end
end
