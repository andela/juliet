class AddProcessedToMedia < ActiveRecord::Migration
  def change
    add_column :media, :processed, :boolean, default: false
    add_column :media, :file_url, :string
  end
end
