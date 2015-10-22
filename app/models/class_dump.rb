class ClassDump < ActiveRecord::Base

  belongs_to :ipa_snapshot
  belongs_to :ios_device

  has_attached_file :class_dump

  validates_attachment_file_name :class_dump, :matches => [/txt\Z/]

  enum error_code: [:devices_busy, :ssh_failure]

end
