class AddPathAndRequestToTestResults < ActiveRecord::Migration[5.2]
  def change
    add_column :test_results, :path, :string
    add_column :test_results, :request, :string
  end
end
