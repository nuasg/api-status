class ChangeTypeToSeverityNotices < ActiveRecord::Migration[5.2]
  def change
    change_table :notices do |t|
      t.rename :type, :severity
    end
  end
end
