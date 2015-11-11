class CocoapodMetricsServiceWorker

  include Sidekiq::Worker

  sidekiq_options :retry => 2, queue: :default

  IGNORE_ROWS = %w(id updated_at created_at ios_sdk_id)


  def perform(metrics_row_id)
    metrics_row = CocoapodMetric.find(metrics_row_id)

    begin
      update_metrics(ios_sdk_id, metrics_row)
    rescue => e
      CocoapodMetricException.create!({
        cocoapod_metric_id: metrics_row.id,
        error: e.message,
        backtrace: e.backtrace
      })

      metrics_row[:success] = false
      metrics_row.save
      
      raise e
    end
  end

  def update_metrics(ios_sdk_id, metrics_row)

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

    row[:success] = true
    metrics_row.update(row)

  end

  def get_metrics(sdk_name)
    data = Proxy.get_from_url("http://metrics.cocoapods.org/api/v1/pods/#{sdk_name}.json")

    JSON.parse(data.body) if data.status == 200
  end
end 