class AddAttachmentZipToApkFiles < ActiveRecord::Migration
  def change
    add_attachment :apk_files, :zip
  end
end
