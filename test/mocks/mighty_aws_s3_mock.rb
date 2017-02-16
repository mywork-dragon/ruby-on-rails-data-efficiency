class MightyAwsS3Mock
  attr_accessor :data, :key_stored_to, :key_returned_from, :key_downloaded_from, :downloaded_to

  def store(bucket:, key_path:, data_str:)
    @data = data_str
    @key_stored_to = key_path
  end

  def retrieve(bucket:, key_path:)
    @key_returned_from = key_path

    raise MightyAws::S3::NoSuchKey unless key_path == @key_stored_to
    @data
  end

  def list(bucket:, prefix:)
    @key_returned_from = prefix
    res = MiniTest::Mock.new
    res.expect(:contents, 4.times.map { |x| S3Object.new })
    res
  end
  
  def download_file(bucket:, key_path:, file_path:)
    @key_downloaded_from = key_path
    @downloaded_to = file_path
    contents = 'Mock file contents'
  end

  class S3Object
    attr_accessor :key

    def initialize
      @key = 'key'
    end
  end
end
