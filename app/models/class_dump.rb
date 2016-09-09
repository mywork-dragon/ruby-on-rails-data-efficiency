class ClassDump < ActiveRecord::Base

  belongs_to :ipa_snapshot
  belongs_to :ios_device
  belongs_to :apple_account

  has_attached_file :class_dump, bucket: Proc.new {|a| a.instance.get_s3_bucket}

  validates_attachment_file_name :class_dump, :matches => [/txt\Z/]

  has_attached_file :app_content, bucket: Proc.new {|a| a.instance.get_s3_bucket}

  validates_attachment_file_name :app_content, :matches => [/tgz\Z/]

  enum error_code: [:devices_busy, :ssh_failure, :no_apple_accounts]

  def get_s3_bucket
    Rails.env.production? ? "varys-apk-files" : "varys-apk-files-development"
  end

end
