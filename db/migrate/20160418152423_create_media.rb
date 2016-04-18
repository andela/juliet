class CreateMedia < ActiveRecord::Migration
  def change
    create_table :media do |t|
      t.string :file_name
      t.string :cloud_url

      t.timestamps null: false
    end
  end
end
