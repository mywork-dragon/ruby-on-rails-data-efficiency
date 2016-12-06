class User < ActiveRecord::Base

  belongs_to :account

  has_many :lists_users
  has_many :lists, through: :lists_users

  has_many :users_countries

  has_many :follow_relationships
  has_many :followed_ios_sdks, through: :follow_relationships, source: :followable, source_type: 'IosSdk'
  has_many :followed_android_apps, through: :follow_relationships, source: :followable, source_type: 'AndroidApp'
  has_many :followed_ios_apps, through: :follow_relationships, source: :followable, source_type: 'IosApp'
  has_many :followed_android_sdks, through: :follow_relationships, source: :followable, source_type: 'AndroidSdk'
  has_secure_password
  validates_uniqueness_of :email

  def as_json(options={})
    super(except: :password_digest).merge(type: self.class.name, following_count: follow_relationships.size)
  end

  def self.from_auth(params, token)
    params = params.with_indifferent_access
    # if the user is coming from an invite
    if token && decoded_token = AuthToken.decode(token)
      return if User.where("#{params[:provider]}_uid = ?", params[:uid]).first
      user = User.find(decoded_token["user_id"])
      if user.send("#{params[:provider]}_uid").blank?
        user.send("#{params[:provider]}_uid=", params[:uid])
        user.send("#{params[:provider]}_token=", params[:token])
        user.first_name = params[:first_name]
        user.last_name = params[:last_name]
        user.profile_url = params["#{params[:provider]}_profile"]
        user.save
        user
      end
    # we are logging in a user that has already previously connected linkedin or google
    elsif user = User.where("#{params[:provider]}_uid = ?", params[:uid]).first
      user.send("#{params[:provider]}_token=", params[:token])
      user.save
      user
    end
  end

  def generate_auth_token
    payload = { user_id: self.id }
    AuthToken.encode(payload)
  end

  def territories
    self.users_countries.map{ |user_country|
      country = ISO3166::Country.new(user_country.country_code)
      {
        id: country.alpha2, 
        name: country.name, 
        icon: "/lib/images/flags/#{country.alpha2.downcase}.png"
      }
    }
  end

  def follow(followable)
    self.follow_relationships.create(followable: followable) unless following?(followable)
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

  def weekly_batches(page_num, country_codes=nil)
    time = Time.now - page_num.months
    following = self.followed_ios_sdks.to_a + self.followed_android_sdks.to_a +  self.followed_android_apps.to_a + 
                self.followed_ios_apps.to_a
    
    batches = following.map{|object| 
      object.weekly_batches.where('week >= ? and week < ? and activity_type != ?', time, time + 1.month, WeeklyBatch.activity_types[:entered_top_apps]).order(week: :desc).to_a
    }.flatten

    batches_by_week = {}
    batches.each do |batch|
      next if country_codes && batch.sorted_activities(country_codes: country_codes).empty?

      batches_by_week[batch.week] ||= {}
      if batches_by_week[batch.week][batch.platform] 
        batches_by_week[batch.week][batch.platform] << batch
      else
        batches_by_week[batch.week][batch.platform] = [batch]
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
