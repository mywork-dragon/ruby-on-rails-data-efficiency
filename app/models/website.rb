class Website < ActiveRecord::Base
  belongs_to :company
  belongs_to :ios_app
  
  enum :kind [:primary, :secondary]
end
