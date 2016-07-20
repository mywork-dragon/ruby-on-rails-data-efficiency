class ChangeLeadMessageToText < ActiveRecord::Migration
  def change
    change_column :leads, :message, :text
  end
end
