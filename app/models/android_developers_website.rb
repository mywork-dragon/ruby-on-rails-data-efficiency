class AndroidDevelopersWebsite < ActiveRecord::Base
    belongs_to :android_developer
    belongs_to :website
end
