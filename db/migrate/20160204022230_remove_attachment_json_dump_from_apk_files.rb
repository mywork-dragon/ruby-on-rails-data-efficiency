class RemoveAttachmentJsonDumpFromApkFiles < ActiveRecord::Migration
  def change
    remove_attachment :apk_files, :json_dump
  end
end
