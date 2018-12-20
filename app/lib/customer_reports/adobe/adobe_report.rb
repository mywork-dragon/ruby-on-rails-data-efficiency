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
      s3 = MightyAws::S3.new.retrieve( bucket: S3_REPORTS_BUCKET, key_path: S3_INPUT_PATH + file_name )


      p s3
    end
  end
end
