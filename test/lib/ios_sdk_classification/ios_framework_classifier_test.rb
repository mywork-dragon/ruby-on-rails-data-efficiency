require 'test_helper'
require "#{Rails.root}/app/lib/ios_sdk_classification/ios_framework_classifier"

class IosFrameworkClassifierTest < ActiveSupport::TestCase
  def setup
    @sdk = IosSdk.create!(name: 'Hello SDK', kind: :native)
  end

  test 'it cannot find non-existing frameworks' do
    sdks = IosFrameworkClassifier.find_from_frameworks(['Nope', 'Hello', 'SDK'])
    assert_equal 0, sdks.length
  end

  test 'it finds exact matches' do
    sdks = IosFrameworkClassifier.find_from_frameworks([@sdk.name])
    assert_equal 1, sdks.length
    assert_equal @sdk.id, sdks.first.id
  end

  test 'it handles the "close enough" case' do
    sdks = IosFrameworkClassifier.find_from_frameworks(['Hello_SDK'])
    assert_equal 1, sdks.length
    assert_equal @sdk.id, sdks.first.id
  end
end
