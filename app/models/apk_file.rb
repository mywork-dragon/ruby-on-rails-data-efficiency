class ApkFile < ActiveRecord::Base

  has_many :apk_snapshots

  has_attached_file :apk, bucket: Proc.new {|a| a.instance.get_s3_bucket}
  validates_attachment_file_name :apk, matches: [/apk\Z/]

  # a dump of data that contains possible SDKs
  has_attached_file :zip, bucket: Proc.new {|a| a.instance.get_s3_bucket}
  validates_attachment_file_name :zip, matches: [/\.zip\z/]

  def s3_client=(value)
      @s3_client = value
  end

  def s3_client
    @s3_client ||= MightyAws::S3.new(Rails.application.config.app_pkg_summary_bucket_region)
    @s3_client
  end

  def s3_classes_key
    # Key is the sha1 of the url path
    prefix = Digest::SHA1.hexdigest(URI.parse(zip.url).path)
    "classes/#{prefix}.classes.gz"
  end

  def upload_class_summary(classes)
    # Uploads an sdk summary to s3.
    s3_client.store(
      bucket: Rails.application.config.app_pkg_summary_bucket,
      key_path: s3_classes_key,
      data_str: classes.join("\n"))
  end

  def classes
    s3_client.retrieve(
      bucket: Rails.application.config.app_pkg_summary_bucket,
      key_path: s3_classes_key).split("\n")
  end

  def get_s3_bucket
    Rails.env.production? ? "varys-apk-files" : "varys-apk-files-development"
  end
end
