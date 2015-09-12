class AndroidSdkCompaniesAndroidApp < ActiveRecord::Base

  belongs_to :android_sdk_company
  belongs_to :android_app

end
