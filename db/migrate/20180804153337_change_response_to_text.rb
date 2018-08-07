class ChangeResponseToText < ActiveRecord::Migration[5.2]
  def change
    change_column :test_results, :response, :text
  end
end
