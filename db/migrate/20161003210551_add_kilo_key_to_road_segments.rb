class AddKiloKeyToRoadSegments < ActiveRecord::Migration
  def change
    add_column :road_segments, :kilo_key, :string, limit: 10
    add_index :road_segments, [ :kilo_key ], name: 'index_road_segments_on_kilo_key'
    
    # generate kilo key and update record
    RoadSegment.find_each do |segment|
      segment.generate_kilo_key
      segment.save!
    end
  end
end
