class AddUrgentToSquares < ActiveRecord::Migration[7.0]
  def change
    add_column :squares, :urgent, :boolean, default: false
    add_index :squares, :urgent
  end
end
