class ItunesS3Store

  class InvalidType < RuntimeError; end

  attr_writer :s3_client

  def initialize
    @s3_client ||= MightyAws::S3.new
  end

  def store!(app_identifier, country_code, data_type, data_str)
    validate_type!(data_type)
    validate_json!(data_str) if data_type == :json
    @s3_client.store(
      bucket: bucket,
      key_path: s3_key_path(app_identifier, country_code, data_type),
      data_str: data_str
    )
  end

  def validate_type!(data_type)
    raise InvalidType unless [:html, :json].include?(data_type)
  end

  def validate_json!(data_str)
    JSON.parse(data_str)
  end

  def bucket
    Rails.application.config.itunes_scrape_bucket
  end

  def s3_key_path(app_identifier, country_code, data_type)
    File.join(
      app_identifier.to_s,
      country_code,
      data_type.to_s,
      "#{Time.now.utc.iso8601}.#{data_type.to_s}.gz"
    )
  end
end
