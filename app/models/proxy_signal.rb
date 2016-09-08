class ProxySignal < ActiveRecord::Base
  before_create :set_updated

  def set_updated
    self.updated_time = updated_time || Time.now
  end
end
