class ManualAppDeveloper < ActiveRecord::Base
  serialize :ios_developer_ids, Array
  serialize :android_developer_ids, Array
end
