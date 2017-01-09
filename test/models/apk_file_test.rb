require 'test_helper'
require 'mocks/mighty_aws_s3_mock'

class ApkFileTest < ActiveSupport::TestCase
  test "store and get class lists" do

    # Mock a zip/apk file
    stringio = Zip::OutputStream.write_buffer do |zio|
      zio.put_next_entry("classes.dex")
      zio.write ""
    end
    stringio.rewind

    apk_file = ApkFile.new
    # Inject a mock s3_client
    s3 = MightyAwsS3Mock.new
    apk_file.s3_client = s3

    # Save the file
    apk_file.zip = stringio
    apk_file.zip_file_name = "test.zip"
    apk_file.save!

    # Trigger a class summary upload.
    apk_file.upload_class_summary(['test.class', 'test.class2'])

    # Ensure the correct data was written.
    assert_equal "test.class\ntest.class2", s3.data
    assert_equal ['test.class', 'test.class2'], apk_file.classes
    assert_equal s3.key_stored_to,  s3.key_returned_from
  end
end
