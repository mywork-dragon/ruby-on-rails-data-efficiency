class AppDevelopersDeveloper < ActiveRecord::Base
  belongs_to :app_developer
  belongs_to :developer, polymorphic: true
end
