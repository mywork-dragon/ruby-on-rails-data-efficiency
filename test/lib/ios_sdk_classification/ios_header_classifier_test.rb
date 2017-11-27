require 'test_helper'
require "#{Rails.root}/app/lib/ios_sdk_classification/ios_header_classifier"

class IosHeaderClassifierTest < ActiveSupport::TestCase

  def setup
    @sdks = 4.times.map do |i|
      IosSdk.create!(name: "TEST#{i}", kind: :native)
    end
    @doc = AppleDoc.create!(name: 'TEST3')
    @classifier = IosHeaderClassifier
  end

  # DEPRECATED FEATURE
  # test 'matches direct lookup' do
  #   direct_sdk = @sdks.first
  #   sdks = @classifier.sdks_from_classnames(classes: [direct_sdk.name])
  #   assert_equal 1, sdks.count
  #   assert_equal direct_sdk.id, sdks.first.id
  # end

  test 'matches unique headers to sdks' do
    unique_sdk = @sdks.first
    header_name = 'somejunk'
    IosClassificationHeader.create!(
      name: header_name, 
      ios_sdk_id: unique_sdk.id, 
      is_unique: true)
    sdks = @classifier.sdks_from_classnames(classes: [header_name])
    assert_equal 1, sdks.count
    assert_equal unique_sdk.id, sdks.first.id
  end

  # DEPRECATED FEATURE
  # test 'excludes direct matches from collision resolution' do
  #   direct_sdk = @sdks.first
  #   collision_sdk = @sdks.second
  #   header_name = 'somejunk'
  #   IosClassificationHeader.create!(
  #     name: header_name, 
  #     ios_sdk_id: collision_sdk.id, 
  #     is_unique: false,
  #     collision_sdk_ids: [direct_sdk.id, collision_sdk.id])
  #   sdks = @classifier.sdks_from_classnames(classes: [header_name, direct_sdk.name])
  #   assert_equal 1, sdks.count
  #   assert_equal direct_sdk.id, sdks.first.id
  # end

  test 'excludes unique matches from collision resolution' do
    unique_sdk = @sdks.first
    collision_sdk = @sdks.second
    header1 = IosClassificationHeader.create!(
      name: 'randomheader1', 
      ios_sdk_id: unique_sdk.id,
      is_unique: true)
    header2 = IosClassificationHeader.create!(
      name: 'randomheader2', 
      ios_sdk_id: collision_sdk.id, 
      is_unique: false,
      collision_sdk_ids: [unique_sdk.id, collision_sdk.id])
    sdks = @classifier.sdks_from_classnames(classes: [header1.name, header2.name])
    assert_equal 1, sdks.count
    assert_equal unique_sdk.id, sdks.first.id
  end

  test 'apple docs toggle works' do
    s = @sdks.last
    header1 = IosClassificationHeader.create!(
      name: @doc.name, 
      ios_sdk_id: s.id,
      is_unique: true)
    sdks = @classifier.sdks_from_classnames(classes: [@doc.name])
    assert_empty sdks
    sdks = @classifier.sdks_from_classnames(classes: [@doc.name], remove_apple: false)
    assert s.id, sdks.first.id
  end
end
