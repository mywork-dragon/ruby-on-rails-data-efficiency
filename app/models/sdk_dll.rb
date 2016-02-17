class SdkDll < ActiveRecord::Base

  has_many :apk_snapshots_sdk_dlls
  has_many :apk_snapshots, through: :apk_snapshots_sdk_dlls

  has_many :ipa_snapshots_sdk_dlls
  has_many :ipa_snapshots, through: :ipa_snapshots_sdk_dlls

  class << self
    def search_for_ios_dlls(sdk_name, limit: 20)
      results = SdkDll.joins(:ipa_snapshots_sdk_dlls).where(id: SdkDll.where("name LIKE '%#{sdk_name}%'")).group(:sdk_dll_id).count

      results.sort_by {|k,v| -v}.first(20).reduce({}) {|memo, arr| dll = SdkDll.find(arr[0]); memo[dll.name] = arr[1]; memo;}
    end
  end

end
