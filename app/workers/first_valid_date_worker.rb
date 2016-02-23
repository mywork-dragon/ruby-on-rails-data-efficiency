class FirstValidDateWorker
  include Sidekiq::Worker

  sidekiq_options backtrace: true, retry: false, queue: :low

  def perform(ipa_snapshot_id)
    snapshot = IpaSnapshot.find(ipa_snapshot_id)
    snapshot.update(first_valid_date: snapshot.created_at)
  end
end