class ApkFile < ActiveRecord::Base

  has_many :apk_snapshots

  has_attached_file :apk
  validates_attachment_file_name :apk, matches: [/apk\Z/]

  # a dump of data that contains possible SDKs
  has_attached_file :text_files
  validates_attachment_file_name :text_files, matches: [/\.tar\.gz\z/]


end