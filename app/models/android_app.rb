class AndroidApp < ActiveRecord::Base

  validates :app_identifier, uniqueness: true
  belongs_to :app
  
  has_many :android_apps_snapshots
  has_many :websites, through: :android_apps_snapshots


  def get_newest_app_snapshot
    self.android_app_snapshots.max_by do |snapshot|
      snapshot.updated_at
    end
  end
  
  def get_newest_download_snapshot
    self.android_app_download_snapshots.max_by do |snapshot|
      snapshot.updated_at
    end
  end
  
  def get_company
    self.websites.each do |w|
      if w.company.present?
        return w.company
      end
    end
    return nil
  end
end
