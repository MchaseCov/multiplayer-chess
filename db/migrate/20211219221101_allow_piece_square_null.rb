class AllowPieceSquareNull < ActiveRecord::Migration[7.0]
  def change
    change_column_null :pieces, :square_id, true
  end
end
