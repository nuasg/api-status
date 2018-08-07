class CreateTestResults < ActiveRecord::Migration[5.2]
  def change
    create_table :test_results do |t|
      t.datetime :time_run
      t.string :name
      t.string :result
      t.string :response

      t.timestamps
    end
  end
end
