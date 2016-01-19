class ApkFile < ActiveRecord::Base

  has_many :apk_snapshots

  has_attached_file :apk

  validates_attachment_file_name :apk, :matches => [/apk\Z/]

end