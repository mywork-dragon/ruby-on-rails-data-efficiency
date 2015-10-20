class AddClassDumpToClassDumps < ActiveRecord::Migration
  def self.up
    add_attachment :class_dumps, :class_dump
  end

  def self.down
    remove_attachment :class_dumps, :class_dump
  end
end
