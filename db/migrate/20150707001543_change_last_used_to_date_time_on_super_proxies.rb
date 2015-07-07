class ChangeLastUsedToDateTimeOnSuperProxies < ActiveRecord::Migration
  def change
    change_column :super_proxies, :last_used, :datetime
  end
end
