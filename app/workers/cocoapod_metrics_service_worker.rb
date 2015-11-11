class CocoapodMetricsServiceWorker

  include Sidekiq::Worker

  sidekiq_options :retry => 2, queue: :default

  IGNORE_ROWS = %w(id updated_at created_at ios_sdk_id)


  def perform(ios_sdk_id)
    begin
      update_metrics(ios_sdk_id)
    rescue => e
      CocoapodMetricException.create!({
        ios_sdk_id: ios_sdk_id,
        error: e.message,
        backtrace: e.backtrace
      })

      raise e
    end
  end

  def update_metrics(ios_sdk_id)

    sdk_name = IosSdk.find(ios_sdk_id).name
    metrics = get_metrics(sdk_name)

    raise "Could not get data for cocoapod #{sdk_name}" if !metrics

    row = {}

    CocoapodMetric.columns.each do |col|
      next if IGNORE_ROWS.include?(col.name)

      parts = col.name.split("_")
      subobject = parts.shift
      property = parts.join("_")

      data = metrics[subobject] ? metrics[subobject][property] : nil
      data = DateTime.parse(data) if col.type == :datetime && data
      row[col.name] = data
    end

    ios_sdk = IosSdk.find_by_name(sdk_name)
    row[:ios_sdk_id] = ios_sdk.id

    begin
      CocoapodMetric.create!(row)
    rescue
      CocoapodMetric.find_by_ios_sdk_id(ios_sdk.id).update(row)
    end
  end

  def get_metrics(sdk_name)
    data = Proxy.get_from_url("http://metrics.cocoapods.org/api/v1/pods/#{sdk_name}.json")

    JSON.parse(data.body) if data.status == 200
  end
end 