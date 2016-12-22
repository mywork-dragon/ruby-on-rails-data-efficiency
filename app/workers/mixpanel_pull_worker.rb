class MixpanelPullWorker

  include Sidekiq::Worker

  sidekiq_options retry: false, queue: :mixpanel_analytics

  def default_data_getter
    CustomerHappinessService.new
  end

  def initialize(data_getter = default_data_getter)
    @data_getter = data_getter
  end

  def perform(from_date)
    # Call Jason's function here.
    # Expect format:
    # { "me@something.com" => {
    #     "timeline": Date.new(2016, 12, 1),
    #     "filtering": Date.new(2016, 12, 1)},
    #   "me@something.com"=> {
    #     "timeline": Date.new(2016, 12, 1),
    #     "filtering": Date.new(2016, 12, 1)
    # }
    if from_date.is_a? String
      from_date = Date.parse from_date
    end

    user_data = @data_getter.users_last_used_events(from_date)
    user_data.each do |email, website_features|
      user = User.find_by_email!(email)
      website_features.each do |feature, last_used|
        user.record_feature_use(feature, last_used)
      end
    end
  end

end
