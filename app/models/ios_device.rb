class IosDevice < ActiveRecord::Base

	has_many :class_dump
  belongs_to :softlayer_proxy

	validates :ip, uniqueness: true
	validates :serial_number, uniqueness: true, presence: true

	# either dedicated for a one off scrape or for mass scrapes
	enum purpose: [:one_off, :mass]

end
