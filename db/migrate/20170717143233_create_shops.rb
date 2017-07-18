class CreateShops < ActiveRecord::Migration
  def change
    create_table :shops do |t|
      t.string :name
      t.integer :status_id
      t.string :url
      t.string :phone

      t.timestamps null: false
    end
  end
end
