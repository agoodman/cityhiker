class CreateOpenStreetMapNodes < ActiveRecord::Migration
  def change
    create_table :open_street_map_nodes do |t|
      t.string :ref
      t.float :lat
      t.float :lng

      t.timestamps null: false
    end
  end
end
