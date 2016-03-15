class ApkFile < ActiveRecord::Base

  has_many :apk_snapshots

  has_attached_file :apk, bucket: Proc.new {|a| a.instance.get_s3_bucket}
  validates_attachment_file_name :apk, matches: [/apk\Z/]

  # a dump of data that contains possible SDKs
  has_attached_file :zip, bucket: Proc.new {|a| a.instance.get_s3_bucket}
  validates_attachment_file_name :zip, matches: [/\.zip\z/]

  def get_s3_bucket
    Rails.env.production? ? "varys-apk-files" : "varys-apk-files-development"
  end
end