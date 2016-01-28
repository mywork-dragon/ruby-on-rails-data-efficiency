class AddAttachmentClassDumpToApkFiles < ActiveRecord::Migration
  def self.up
    change_table :apk_files do |t|
      t.attachment :class_dump
    end
  end

  def self.down
    remove_attachment :apk_files, :class_dump
  end
end
