class AddTypeIndexToPieces < ActiveRecord::Migration[7.0]
  def change
    add_index :pieces, :type
  end
end
