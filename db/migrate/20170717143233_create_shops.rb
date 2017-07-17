class CreateShops < ActiveRecord::Migration
  def change
    create_table :shops do |t|
      t.string :name
      t.string :status
      t.string :url
      t.string :phone

      t.timestamps null: false
    end
  end
end
