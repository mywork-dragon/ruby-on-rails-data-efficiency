class AddColumnAppContentToClassDumps < ActiveRecord::Migration
  def change
    add_attachment :class_dumps, :app_content
  end
end
