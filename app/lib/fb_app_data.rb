class FbAppData

  attr_reader :fb_app_id
  attr_writer :s3_client

  class Unavailable; end

  def initialize(fb_app_id)
    @fb_app_id = fb_app_id
  end

  def s3_client
    @s3_client ||= MightyAws::S3.new
    @s3_client
  end

  def latest
    JSON.parse(s3_client.retrieve(
      bucket: bucket,
      key_path: latest_key
    ))
  rescue MightyAws::S3::NoSuchKey
    Unavailable
  end

  def bucket
    Rails.application.config.fb_mau_scrape_bucket
  end

  def store(data)
    store_historical(data)
    store_latest(data)
  end

  def historical_key
    File.join('historical', @fb_app_id.to_s, "#{Time.now.utc.iso8601}.json.gz")
  end

  def latest_key
    File.join('latest', "#{@fb_app_id}.json.gz")
  end

  def store_historical(json)
    s3_client.store(
      bucket: bucket,
      key_path: historical_key,
      data_str: json.to_json
    )
  end

  def store_latest(json)
    s3_client.store(
      bucket: bucket,
      key_path: latest_key,
      data_str: json.to_json
    )
  end

end
