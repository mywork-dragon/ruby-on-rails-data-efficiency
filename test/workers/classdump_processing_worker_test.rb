require 'test_helper'
require 'mocks/mighty_aws_s3_mock'

class ClassdumpProcessingWorkerTest < ActiveSupport::TestCase
  def setup
    @s3 = MightyAwsS3Mock.new
    @classdump = ClassDump.create!
    @classdump.s3_client = @s3
  end

  test 'the truth' do
    assert true
  end

  test 'yo' do
    assert true
  end
end
