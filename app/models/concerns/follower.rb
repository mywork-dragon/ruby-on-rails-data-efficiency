module Follower
  extend ActiveSupport::Concern

  included do
    has_many :follow_relationships, as: :follower
    has_many :followed_ios_sdks, through: :follow_relationships, source: :followable, source_type: 'IosSdk'
    has_many :followed_android_apps, through: :follow_relationships, source: :followable, source_type: 'AndroidApp'
    has_many :followed_ios_apps, through: :follow_relationships, source: :followable, source_type: 'IosApp'
    has_many :followed_android_sdks, through: :follow_relationships, source: :followable, source_type: 'AndroidSdk'
  end

  def follow(followable)
    self.follow_relationships.create(followable: followable) unless following?(followable)
    Rails.cache.delete(cache_key)
  end

  def unfollow(followable)
    self.follow_relationships.where(followable: followable).destroy_all
    Rails.cache.delete(cache_key)
  end

  def following?(followable)
    self.follow_relationships.where(followable: followable).any?
  end

  def following
    followed_ios_sdks.to_a + followed_android_apps.to_a + followed_ios_apps.to_a + followed_android_sdks.to_a
  end

  def cache_key
    "follower:following:#{self.class.to_s}:#{self.id}"
  end

  def following_as_json(options={})
    Rails.cache.fetch(cache_key, expires: 48.hours, compress: true) do
      JSON.parse following.to_json(options)
    end
  end

end
