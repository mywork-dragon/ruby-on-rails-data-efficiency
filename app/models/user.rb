class User < ActiveRecord::Base

  belongs_to :account

  has_many :lists_users
  has_many :lists, through: :lists_users

  has_many :follow_relationships
  has_many :followed_ios_sdks, through: :follow_relationships, source: :followable, source_type: 'IosSdk'
  has_many :followed_android_apps, through: :follow_relationships, source: :followable, source_type: 'AndroidApp'
  has_many :followed_ios_apps, through: :follow_relationships, source: :followable, source_type: 'IosApp'
  has_many :followed_android_sdks, through: :follow_relationships, source: :followable, source_type: 'AndroidSdk'
  has_secure_password
  validates_uniqueness_of :email

  def generate_auth_token
    payload = { user_id: self.id }
    AuthToken.encode(payload)
  end

  def follow(followable)
    self.follow_relationships.create(followable: followable)
  end

  def unfollow(followable)
    self.follow_relationships.where(followable: followable).destroy_all
  end

  def following?(followable)
    self.follow_relationships.where(followable: followable).any?
  end

  def following
    followed_ios_sdks.to_a + followed_android_apps.to_a + followed_ios_apps.to_a + followed_android_sdks.to_a
  end

  def weekly_batches
    following = self.followed_ios_sdks.to_a + self.followed_android_sdks.to_a +  self.followed_android_apps.to_a + 
               self.followed_ios_apps.to_a
    following << AdPlatform.facebook if self.account.can_view_ad_spend
    
    batches = following.map{|object| 
      object.weekly_batches.to_a
    }.flatten

    batches_by_week = {}
    batches.each do |batch|
      if batches_by_week[batch.week] 
        batches_by_week[batch.week] << batch
      else
        batches_by_week[batch.week] = [batch]
      end
    end
    batches_by_week.sort_by{|k,v| -(k.to_time.to_i)}
  end

  class << self
    
    # Get the user by credentials, else return nil
    # @author Jason Lew
    # @note Be careful editing this method
    def find_by_credentials(email, password)
      
      user = User.find_by_email(email)
      
      return nil if user.nil?
      
      return user if user.authenticate(password)
      
      nil
    end
    
  end

end
