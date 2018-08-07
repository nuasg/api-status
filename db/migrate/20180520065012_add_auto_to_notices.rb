class AddAutoToNotices < ActiveRecord::Migration[5.2]
  def change
    add_column :notices, :auto, :boolean, default: false
  end
end
