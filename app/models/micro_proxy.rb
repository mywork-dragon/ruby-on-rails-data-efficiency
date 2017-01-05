class MicroProxy < ActiveRecord::Base
	has_many :apk_snapshots

  enum purpose: [:general, :ios, :android, :region]

  include ProxyRegions
end
