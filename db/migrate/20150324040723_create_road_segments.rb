class CreateRoadSegments < ActiveRecord::Migration
  def change
    create_table :road_segments do |t|
      t.float :start_lat
      t.float :start_lng
      t.float :end_lat
      t.float :end_lng
      t.float :start_alt
      t.float :end_alt
      t.float :percent_grade

      t.timestamps null: false
    end
  end
end
