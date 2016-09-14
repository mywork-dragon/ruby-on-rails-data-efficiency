class MicroProxy < ActiveRecord::Base
	has_many :apk_snapshots

  enum purpose: [:general, :ios, :android, :temporary]
end
