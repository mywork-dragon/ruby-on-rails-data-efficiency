module Taggable
  extend ActiveSupport::Concern

  included do
    has_many :tag_relationships, :as => :taggable
  end
end
