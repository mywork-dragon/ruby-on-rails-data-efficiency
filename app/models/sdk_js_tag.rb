class SdkJsTag < ActiveRecord::Base

  has_many :apk_snapshots_sdk_js_tags
  has_many :apk_snapshots, through: :apk_snapshots_sdk_js_tags

  has_many :ipa_snapshots_sdk_js_tags
  has_many :ipa_snapshots, through: :ipa_snapshots_sdk_js_tags

  class << self
    def search_for_ios_tags(sdk_name, limit: 20)
      results = SdkJsTag.joins(:ipa_snapshots_sdk_js_tags).where(id: SdkJsTag.where("name LIKE '%#{sdk_name}%'")).group(:sdk_js_tag_id).count

      results.sort_by {|k,v| -v}.first(20).reduce({}) {|memo, arr| tag = SdkJsTag.find(arr[0]); memo[tag.name] = arr[1]; memo;}
    end
  end

end
