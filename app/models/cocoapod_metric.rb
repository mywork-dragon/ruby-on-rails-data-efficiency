class CocoapodMetric < ActiveRecord::Base
  belongs_to :ios_sdk
  has_many :cocoapod_metric_exceptions
end
