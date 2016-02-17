class IpaSnapshotsSdkDll < ActiveRecord::Base
  belongs_to :ipa_snapshot
  belongs_to :sdk_dll
end
