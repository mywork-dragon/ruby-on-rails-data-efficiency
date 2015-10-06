class Cocoapod < ActiveRecord::Base

	has_many :cocoapod_authors

	has_many :cocoapod_tags

	has_many :cocoapod_source_datas

end
