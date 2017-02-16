require 'test_helper'
require 'mocks/mighty_aws_s3_mock'

class ClassdumpProcessingWorkerTest < ActiveSupport::TestCase
  def setup
    @s3 = MightyAwsS3Mock.new
    @classdump = ClassDump.create!
    @classdump.s3_client = @s3

    @worker = ClassdumpProcessingWorker.new
    @jtool = Jtool.new
    @worker.jtool = @jtool
  end

  test 'gets both classes and libraries from binary data' do
    classes = ['Class1', 'Class2']
    libraries = ['@rpath/Frameworks/Aether.framework']
    @jtool.stub :objc_classes, classes do
      @jtool.stub :shared_libraries, libraries do
        output = @worker.binary_data(@classdump, 'some_key')
        assert_equal output[:classes], classes
        assert_equal output[:libraries], libraries
        assert_equal 'some_key', @s3.key_downloaded_from
        assert %r{/tmp/.+}.match(@s3.downloaded_to)
      end
    end
  end

  test 'combines classes and library data' do
    binary_data_stub = Proc.new do |classdump, binary_key| 
      {
        classes: 2.times.map { |x| Digest::SHA1.hexdigest(rand.to_s) },
        libraries: 2.times.map { |x| Digest::SHA1.hexdigest(rand.to_s) }
      }
    end

    @worker.stub :binary_data, binary_data_stub do
      result = @worker.combined_binary_data(@classdump)
      assert result[:classes].class == Array
      assert result[:libraries].class == Array
      assert result[:classes].first.class == String
      assert result[:libraries].first.class == String
      assert result[:classes].count > 2 # assumes more than 1 binary
      assert result[:libraries].count > 2 # assumes more than 1 binary
    end
  end
end
