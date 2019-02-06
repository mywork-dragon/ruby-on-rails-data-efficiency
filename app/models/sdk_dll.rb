# == Schema Information
#
# Table name: sdk_dlls
#
#  id         :integer          not null, primary key
#  name       :string(191)
#  created_at :datetime
#  updated_at :datetime
#

class SdkDll < ActiveRecord::Base

  has_many :apk_snapshots_sdk_dlls
  has_many :apk_snapshots, through: :apk_snapshots_sdk_dlls

  has_many :ipa_snapshots_sdk_dlls
  has_many :ipa_snapshots, through: :ipa_snapshots_sdk_dlls

  class << self
    def search_for_dlls(name:, platform:, limit: 20)
      map = {
        ios: :ipa_snapshots_sdk_dlls,
        android: :apk_snapshots_sdk_dlls
      }

      results = SdkDll.joins(map[platform]).where(id: SdkDll.where("name LIKE '%#{name}%'")).group(:sdk_dll_id).count

      results.sort_by {|k,v| -v}.first(20).reduce({}) {|memo, arr| dll = SdkDll.find(arr[0]); memo[dll.name] = arr[1]; memo;}
    end
  end

end
