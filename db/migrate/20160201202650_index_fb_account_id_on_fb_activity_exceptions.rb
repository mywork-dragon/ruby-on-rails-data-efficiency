class IndexFbAccountIdOnFbActivityExceptions < ActiveRecord::Migration
  def change
    add_index :fb_activity_exceptions, :fb_account_id
  end
end
