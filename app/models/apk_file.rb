class ApkFile < ActiveRecord::Base

  has_many :apk_snapshots

  has_attached_file :apk

  validates_attachment_file_name :apk, matches: [/apk\Z/]

  has_attached_file :class_dump
  validates_attachment_file_name :class_dump, matches: [/txt\Z/]

end