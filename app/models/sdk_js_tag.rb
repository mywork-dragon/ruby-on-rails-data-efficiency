# == Schema Information
#
# Table name: sdk_js_tags
#
#  id         :integer          not null, primary key
#  name       :string(191)
#  created_at :datetime
#  updated_at :datetime
#

class SdkJsTag < ActiveRecord::Base

  has_many :apk_snapshots_sdk_js_tags
  has_many :apk_snapshots, through: :apk_snapshots_sdk_js_tags

  has_many :ipa_snapshots_sdk_js_tags
  has_many :ipa_snapshots, through: :ipa_snapshots_sdk_js_tags

  class << self
    def search_for_js_tags(name:, platform:, limit: 20)
      map = {
        ios: :ipa_snapshots_sdk_js_tags,
        android: :apk_snapshots_sdk_js_tags
      }

      results = SdkJsTag.joins(map[platform]).where(id: SdkJsTag.where("name LIKE '%#{name}%'")).group(:sdk_js_tag_id).count

      results.sort_by {|k,v| -v}.first(20).reduce({}) {|memo, arr| dll = SdkJsTag.find(arr[0]); memo[dll.name] = arr[1]; memo;}
    end
  end

end
