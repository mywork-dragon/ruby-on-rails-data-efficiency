class ItunesS3Store

  class InvalidType < RuntimeError; end

  attr_writer :s3_client

  def initialize(app_identifier, country_code, data_type:, data_str:)
    @data_type = data_type
    @data_str = data_str
    @app_identifier = app_identifier
    @country_code = country_code

    validate_type!
  end

  def store!
    s3_client.store(
      bucket: bucket,
      key_path: s3_key_path,
      data_str: @data_str
    )
  end

  def validate_type!
    raise InvalidType unless [:html, :json].include?(@data_type)
  end

  def s3_client
    @s3_client ||= MightyAws::S3.new
    @s3_client
  end

  def bucket
    Rails.application.config.itunes_scrape_bucket
  end

  def s3_key_path
    File.join(
      @app_identifier.to_s,
      @country_code,
      @data_type.to_s,
      "#{Time.now.utc.iso8601}.#{@data_type.to_s}.gz"
    )
  end
end
