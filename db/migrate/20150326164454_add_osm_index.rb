class AddOsmIndex < ActiveRecord::Migration

  def change
    add_index :open_street_map_nodes, [ :ref ]
    add_index :open_street_map_ways, [ :ref ]
  end

end
