class RemoveCaptureFromTurn < ActiveRecord::Migration[7.0]
  def change
    remove_column :turns, :capture, :boolean
  end
end
