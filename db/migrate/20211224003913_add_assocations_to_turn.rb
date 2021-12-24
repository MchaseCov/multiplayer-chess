class AddAssocationsToTurn < ActiveRecord::Migration[7.0]
  def change
    add_reference :turns, :start_piece, null: false, foreign_key: { to_table: :pieces }
    add_reference :turns, :end_piece, null: true, foreign_key: { to_table: :pieces }
    add_reference :turns, :start_square, null: false, foreign_key: { to_table: :squares }
    add_reference :turns, :end_square, null: false, foreign_key: { to_table: :squares }
  end
end
