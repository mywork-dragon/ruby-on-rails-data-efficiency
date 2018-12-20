# == Schema Information
#
# Table name: ahoy_events
#
#  id         :integer          not null, primary key
#  visit_id   :integer
#  user_id    :integer
#  name       :string(191)
#  properties :text(65535)
#  time       :datetime
#

class Ahoy::Event < ActiveRecord::Base
  include Ahoy::QueryMethods

  self.table_name = "ahoy_events"

  belongs_to :visit
  belongs_to :lead
end
