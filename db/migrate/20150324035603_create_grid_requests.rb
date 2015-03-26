class CreateGridRequests < ActiveRecord::Migration
  def change
    create_table :grid_requests do |t|
      t.integer :min_lat
      t.integer :min_lng
      t.integer :max_lat
      t.integer :max_lng
      t.string :url
      t.time :completed_at

      t.timestamps null: false
    end
  end
end
