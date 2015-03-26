class CreateElevationRequests < ActiveRecord::Migration
  def change
    create_table :elevation_requests do |t|
      t.text :encoded_polyline
      t.string :index_map

      t.timestamps null: false
    end
  end
end
