class RemoveAttachmentClassDumpFromApkFiles < ActiveRecord::Migration
  def change
    remove_attachment :apk_files, :class_dump
  end
end
