class ChangeResponseToMediumText < ActiveRecord::Migration[5.2]
  def change
    change_column :test_results, :response, :text, limit: 16.megabytes - 1
  end
end
