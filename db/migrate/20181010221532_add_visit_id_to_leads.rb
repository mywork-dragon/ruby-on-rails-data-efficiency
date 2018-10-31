class AddVisitIdToLeads < ActiveRecord::Migration
  def change
    add_column :leads, :visit_id, :bigint
  end
end
