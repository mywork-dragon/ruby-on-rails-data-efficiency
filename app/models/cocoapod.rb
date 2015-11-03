class Cocoapod < ActiveRecord::Base
	belongs_to :ios_sdk
	has_many :cocoapod_source_datas
end
