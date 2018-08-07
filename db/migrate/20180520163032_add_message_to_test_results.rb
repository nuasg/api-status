class AddMessageToTestResults < ActiveRecord::Migration[5.2]
  def change
    add_column :test_results, :message, :string
  end
end
