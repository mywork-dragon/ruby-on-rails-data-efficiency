class IosClassificationHeaderWorker
  include Sidekiq::Worker

  sidekiq_options queue: :default, retry: false

  def perform(method, *args)
    send(method.to_sym, *args)
  end

  def queue_headers
    puts "Queueing IosSdkSourceData"
    batch_size = 1_000
    IosSdkSourceData
      .find_in_batches(batch_size: batch_size)
      .with_index do |the_batch, index|
      puts "count: #{batch_size * index}"

      args = the_batch.map do |ios_sdk_source_data|
        [:insert, ios_sdk_source_data.name]
      end

      SidekiqBatchQueueWorker.perform_async(
        IosClassificationHeaderWorker.to_s,
        args,
        bid
      )
    end

    CocoapodSourceData
      .where(flagged: false)
      .find_in_batches(batch_size: batch_size)
      .with_index do |the_batch, index|
      puts "count: #{batch_size * index}"

      args = the_batch.map do |cocoapod_source_data|
        [:insert, cocoapod_source_data.name]
      end

      SidekiqBatchQueueWorker.perform_async(
        IosClassificationHeaderWorker.to_s,
        args,
        bid
      )
    end
  end

  def insert(name)

    if IosClassificationHeadersBackup.find_by_name(name)
      puts "Entry already exists"
      return
    end

    classification_worker = IosClassificationServiceWorker.new
    sdks = classification_worker.source_search(name)

    if sdks.nil? || sdks.empty?
      # should not happen...
      puts "No matching sdks for header #{name}"
    elsif sdks.count == 1
      row = IosClassificationHeadersBackup.new(
        name: name,
        ios_sdk_id: sdks.first.id,
        is_unique: true
      )
     IosClassificationHeadersBackup.import [row] # don't care about collision
    else
      resolved_sdk = classification_worker.resolve_collision(sdks: sdks)
      unless resolved_sdk
        puts "Could not resolve collision for #{name}"
      else
        row = IosClassificationHeadersBackup.new(
          name: name,
          ios_sdk_id: resolved_sdk.id,
          is_unique: false,
          collision_sdk_ids: sdks.map(&:id)
        )
        IosClassificationHeadersBackup.import [row] # don't care about collision
      end
    end
  end

  class << self
    def test
    end
  end
end
