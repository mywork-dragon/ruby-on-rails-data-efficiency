class IpaSnapshotsSdkJsTag < ActiveRecord::Base
  belongs_to :ipa_snapshot
  belongs_to :sdk_js_tag
end
