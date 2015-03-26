class CreateElevationRequestSegments < ActiveRecord::Migration
  def change
    create_table :elevation_request_segments do |t|
      t.integer :elevation_request_id
      t.integer :index
      t.integer :way_id

      t.timestamps null: false
    end
  end
end
