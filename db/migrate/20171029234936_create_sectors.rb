class CreateSectors < ActiveRecord::Migration
  def change
    create_table :sectors do |t|
      t.integer :scale_key
      t.string :cell_key, size: 10
      t.integer :state

      t.timestamps null: false
    end
  end
end
