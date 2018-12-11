# == Schema Information
#
# Table name: cocoapod_metric_exceptions
#
#  id                 :integer          not null, primary key
#  cocoapod_metric_id :integer
#  error              :text(65535)
#  backtrace          :text(65535)
#  created_at         :datetime
#  updated_at         :datetime
#

class CocoapodMetricException < ActiveRecord::Base
  belongs_to :cocoapod_metric
end
