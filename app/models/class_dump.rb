class ClassDump < ActiveRecord::Base

  has_many :ipa_snapshots

  has_attached_file :class_dump

  validates_attachment_file_name :class_dump, :matches => [/txt\Z/]

end
