class AdobeReport

  # This class produces the report for Adobe.
  # It pulls the input data and push the output data to AWS S3.

  ######################## INSTRUCTIONS ################################

  ## TO RUN IT

  # Place the input data in the S3_INPUT_BUCKET url.
  # From terminal you can use:
  # $ awslogin
  # $ aws s3 cp local_folder/file.csv  s3://mightysignal-customer-reports/adobe/input/

  # Make sure the file matches the pattern for the parser version, ex:
  # v1 input file format is a csv with data formatted like this:
  # 1299,"HASBRO, INC.",Y
  # 6219,CAMPBELL SOUP COMPANY,Y
  # 12270,NAVY FEDERAL CREDIT UNION,Y
  # For this we will use parser v1 too.

  # To generate the report, use the Rails runner from the container bash
  # $ rails runner "AdobeReport.generate('v1')"

  # Download the produced files from the S3_OUTPUT_BUCKET url

  S3_REPORTS_BUCKET = 'mightysignal-customer-reports'
  S3_OBJECT = 'adobe/'
  S3_INPUT_PATH   = S3_OBJECT + 'input/'
  S3_OUTPUT_PATH  = S3_OBJECT + 'output/'

  class << self
    # File must be a .gz
    def generate(file_name, version)
      output_file_ios = File.open("/tmp/adobe.ios.output.csv", "w")
      output_file_android = File.open("/tmp/adobe.android.output.csv", "w")
      file_content = MightyAws::S3.new.retrieve( bucket: S3_REPORTS_BUCKET,
                                                 key_path: S3_INPUT_PATH + file_name )
      # file_content = File.read(Rails.root.join('app', 'lib', 'customer_reports', 'adobe', 'publishers.csv'))
      publisher_names = extract_publisher_names(file_content)
      publisher_names.each do |publisher_name|
        more_than_one_found_msg = 'More that one publisher matches that name'

        ios_developers = IosDeveloper.where(name: publisher_name)
        ios_devs_found_amnt = ios_developers.size
        p more_than_one_found_msg + ' (Ios)' if ios_devs_found_amnt > 1

        android_developers = AndroidDeveloper.where(name: publisher_name)
        android_devs_found_amnt = android_developers.size
        p more_than_one_found_msg + ' (Android)' if android_devs_found_amnt.size > 1

        found = false
        if ios_devs_found_amnt >= 1
          found = true
          line = generate_row_ios(ios_developers.first)
          output_file_ios.write(line)
        end

        if android_devs_found_amnt >= 1
          found = true
          line = generate_row_android(android_developer.first)
          output_file_android.write(line)
        end
      end
    rescue IOError => e
      p "Error writing to file"
      p e
    ensure
      output_file_ios.close     unless output_file_ios.nil?
      output_file_android.close unless output_file_android.nil?
    end

    private

    def generate_row_android(publisher)
      'this,is,a,test,android'
    end

    def generate_row_ios(publisher)
      'this,is,a,test,ios'
    end

    def extract_publisher_names(str)
      # Lines come as    "1493687,SB MULTIMEDIA PVT. LTD,Y\r\n"
      # some have quotes "1473563,\"TOYOTA MOTOR NORTH AMERICA, INC.\",Y\r\n",
      str.lines.map { |ln| if ln =~ /(\d+),(.*),(.?)/ then $2 end }.compact
    end
  end
end
