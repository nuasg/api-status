class ChangeNoticeActiveDefault < ActiveRecord::Migration[5.2]
  def change
    change_column_default :notices, :active, true
  end
end
