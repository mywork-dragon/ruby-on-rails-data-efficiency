class AddAttachmentTextFilesToApkFiles < ActiveRecord::Migration
  def change
    add_attachment :apk_files, :text_files
  end
end
