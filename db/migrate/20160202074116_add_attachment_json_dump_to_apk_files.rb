class AddAttachmentJsonDumpToApkFiles < ActiveRecord::Migration
  def change
    add_attachment :apk_files, :json_dump
  end
end
