class MightyAwsS3Mock
  attr_accessor :data
  attr_accessor :key_stored_to
  attr_accessor :key_returned_from

  def store(bucket:, key_path:, data_str:)
    @data = data_str
    @key_stored_to = key_path
  end

  def retrieve(bucket:, key_path:)
    @key_returned_from = key_path

    raise MightyAws::S3::NoSuchKey unless key_path == @key_stored_to
    @data
  end
end
