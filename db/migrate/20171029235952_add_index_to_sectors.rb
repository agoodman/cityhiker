class AddIndexToSectors < ActiveRecord::Migration
  def change
    add_index :sectors, [:scale_key]
    add_index :sectors, [:scale_key, :cell_key]
    add_index :sectors, [:scale_key, :state]
    add_index :sectors, [:state]
  end
end
