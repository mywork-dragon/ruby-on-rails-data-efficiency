class AndroidApp < ActiveRecord::Base

  validates :app_identifier, uniqueness: true

  has_many :android_app_snapshots
  belongs_to :app
  
  has_many :android_apps_snapshots
  has_many :websites, through: :android_apps_snapshots

  class << self
    
    def dedupe
        # find all models and group them on keys which should be common
        grouped = all.group_by{|model| [model.app_identifier] }
        grouped.values.each do |duplicates|
          # the first one we want to keep right?
          first_one = duplicates.shift # or pop for last one
          # if there are any more left, they are duplicates
          # so delete all of them
          duplicates.each do |double| 
            puts "double: #{double.app_identifier}"
            double.destroy # duplicates can now be destroyed
          end
        end
      end
  end

end
