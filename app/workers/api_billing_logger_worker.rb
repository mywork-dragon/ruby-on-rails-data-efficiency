# used in ApiBillingLogger

class ApiBillingLoggerWorker

  include Sidekiq::Worker

  sidekiq_options retry: false, queue: :api_processing

  def perform(event)
    res = MightyAws::Firehose.new.send(
      stream_name: ENV['API_BILLING_LOG_STREAM'].to_s,
      data: event.to_json
    )
  end
end
