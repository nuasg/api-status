class CreateNotices < ActiveRecord::Migration[5.2]
  def change
    create_table :notices do |t|
      t.text :title
      t.text :content
      t.boolean :active
      t.datetime :deactivated

      t.timestamps
    end
  end
end
