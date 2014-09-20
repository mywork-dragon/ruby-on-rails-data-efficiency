class ScrapedResult < ActiveRecord::Base
  belongs_to :company
  has_many :installations
  enum status: [ :success, :fail ]
end
