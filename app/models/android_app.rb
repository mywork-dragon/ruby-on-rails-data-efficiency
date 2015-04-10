class AndroidApp < ActiveRecord::Base

  has_many :android_app_snapshots
  belongs_to :app
  
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
