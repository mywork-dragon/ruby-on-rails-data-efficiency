class AddApkToApkFiles < ActiveRecord::Migration
  def self.up
    add_attachment :apk_files, :apk
  end

  def self.down
    remove_attachment :apk_files, :apk
  end
end
