class AdobeReport

  S3_REPORTS_BUCKET = 'https://s3.amazonaws.com/mightysignal-customer-reports/adobe/'
  S3_ADOBE_BUCKET   = S3_REPORTS_BUCKET + 'adobe/'
  S3_INPUT_BUCKET   = S3_ADOBE_BUCKET + 'input'
  S3_OUTPUT_BUCKET  = S3_ADOBE_BUCKET + 'output'

  class << self
    def create_report
      p S3_RESULT_BUCKET
    end
  end
end
