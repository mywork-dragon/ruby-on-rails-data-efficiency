require 'test_helper'
require "#{Rails.root}/app/lib/ios_sdk_classification/ios_framework_classifier"

class IosFrameworkClassifierTest < ActiveSupport::TestCase
  def setup
    @sdk = IosSdk.create!(name: 'Hello SDK', kind: :native)
    @fw = 'Hello_SDK'
    IosClassificationFramework.create!(name: @fw, ios_sdk: @sdk)
  end

  test 'it cannot find non-existing frameworks including exact match by name' do
    sdks = IosFrameworkClassifier.find_from_frameworks(['Nope', 'Hello', 'SDK', 'Hello SDK'])
    assert_equal 0, sdks.length
  end

  test 'it finds exact matches' do
    sdks = IosFrameworkClassifier.find_from_frameworks([@fw])
    assert_equal 1, sdks.length
    assert_equal @sdk.id, sdks.first.id
  end
end
