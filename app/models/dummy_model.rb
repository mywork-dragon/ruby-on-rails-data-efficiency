# == Schema Information
#
# Table name: dummy_models
#
#  id                :integer          not null, primary key
#  dummy             :string(191)
#  dummy_text        :text(65535)
#  created_at        :datetime
#  updated_at        :datetime
#  is_it_medium_text :text(65535)
#

class DummyModel < ActiveRecord::Base
end
