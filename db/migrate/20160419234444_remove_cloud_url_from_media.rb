class RemoveCloudUrlFromMedia < ActiveRecord::Migration
  def change
    remove_column :media, :cloud_url, :string
    remove_column :users, :attachment, :string
  end
end
