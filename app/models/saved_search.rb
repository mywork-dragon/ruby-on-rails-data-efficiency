class SavedSearch < ActiveRecord::Base

  belongs_to :user

  def update_dates
    params = self.search_params
    (2..6).each do |n|
      params = params.gsub("%22date%22:%22#{n}", "%22date%22:%22#{n + 6}")
    end
    self.update_attribute(:search_params, params)
  end

  def self.update_saved_dates
    all.each { |search| search.update_dates }
  end

end
