module ActiveRecordExtension

  extend ActiveSupport::Concern

  module ClassMethods
    def random(n = nil)
      if n.nil?
        order("rand()").first
      else
        order("rand()").limit(n)
      end
    end
  end
end

ActiveRecord::Base.send(:include, ActiveRecordExtension)