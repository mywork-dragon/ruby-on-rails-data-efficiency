class AddAhoyToLeads < ActiveRecord::Migration
  def change
    add_column :leads, :referrer, :text
    add_column :leads, :referring_domain, :string
    add_column :leads, :utm_source, :string, index: true
    add_column :leads, :utm_medium, :string, index: true
    add_column :leads, :utm_campaign, :string, index: true
    add_column :leads, :landing_page, :string
    add_column :leads, :landing_variant, :string
  end
end
