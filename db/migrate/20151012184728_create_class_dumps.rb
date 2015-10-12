class CreateClassDumps < ActiveRecord::Migration
  def change
    create_table :class_dumps do |t|

      t.timestamps
    end
  end
end
