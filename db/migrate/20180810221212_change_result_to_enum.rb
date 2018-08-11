class ChangeResultToEnum < ActiveRecord::Migration[5.2]
  def change
    result_map = {
        pass: '0',
        warn: '1',
        fail: '2'
    }

    correct = %w(0 1 2)

    index = 1
    TestResult.all.each do |tr|
      console.log index if index % 10 == 0

      next if tr.result.nil?
      next if correct.include? tr.result

      tbm = tr.result.downcase.to_sym
      nr = result_map[tbm]

      tr.update result: nr
    end

    change_column :test_results, :result, :integer
  end
end
