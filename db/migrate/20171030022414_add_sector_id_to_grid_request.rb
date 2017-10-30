class AddSectorIdToGridRequest < ActiveRecord::Migration
  def change
    add_column :grid_requests, :sector_id, :integer
    add_index :grid_requests, [:sector_id]
  end
end
