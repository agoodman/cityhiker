class AddHectoKeyToRoadSegments < ActiveRecord::Migration
  def change
    add_column :road_segments, :hecto_key, :string, limit: 10
    add_index :road_segments, [ :hecto_key ], name: 'index_road_segments_on_hecto_key'
    
    # generate hecto key and update record
    RoadSegment.find_each do |segment|
      segment.generate_hecto_key
      segment.save!
    end
  end
end
