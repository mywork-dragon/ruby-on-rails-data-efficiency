require 'test_helper'

class ApkFileTest < ActiveSupport::TestCase
  test "the truth" do
    data = nil

    class MightyAwsMock
      def store(bucket:, key_path:, data_str:)
        data = data_str
      end
    end

    # Mock a zip/apk file
    stringio = Zip::OutputStream.write_buffer do |zio|
      zio.put_next_entry("classes.dex")
      zio.write ""
    end
    stringio.rewind

    apk_file = ApkFile.new
    # Inject a mock s3_client
    apk_file.s3_client = MightyAwsMock.new

    # Save the file
    apk_file.zip = stringio
    apk_file.zip_file_name = "test.zip"
    apk_file.save!

    # Trigger a class summary upload.
    apk_file.upload_class_summary(['test.class', 'test.class2'])

    # Ensure the correct data was written.
    assert data = "test.class\ntest.class2"
  end
end
