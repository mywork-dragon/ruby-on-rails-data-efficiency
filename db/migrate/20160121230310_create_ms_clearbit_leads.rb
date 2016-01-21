class CreateMsClearbitLeads < ActiveRecord::Migration
  def change
    create_table :ms_clearbit_leads do |t|
      t.text :first_name
      t.text :last_name
      t.text :full_name
      t.text :title
      t.text :email
      t.text :linkedin
      t.text :json_content
      t.timestamps
    end
  end
end
