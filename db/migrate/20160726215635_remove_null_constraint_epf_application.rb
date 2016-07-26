class RemoveNullConstraintEpfApplication < ActiveRecord::Migration
  def change
    change_column :epf_applications, :application_id, :integer, null: true
  end
end
