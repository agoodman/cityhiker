class CreateOpenStreetMapWays < ActiveRecord::Migration
  def change
    create_table :open_street_map_ways do |t|
      t.string :ref
      t.string :nodes

      t.timestamps null: false
    end
  end
end
