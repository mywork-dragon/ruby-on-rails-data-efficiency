class TwitterPostWorker

  include Sidekiq::Worker

  sidekiq_options retry: false, queue: :sdk_live_scan, throttle: { threshold: 1, period: 15.minutes }

  def perform(method, *args)
    self.send(method.to_sym, *args)
  end

  def post_activity(activity_id)
    activity = Activity.find(activity_id)
    TwitterPostService.run(activity)
  end
end