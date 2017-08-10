require 'test_helper'

class RedshiftLoggerTest < ActiveSupport::TestCase

  test 'add records puts in the default fields' do
    logger = RedshiftLogger.new(table: 'sup', database: 'sup', cluster: 'sup')
    logger.add({a: 5})
    assert_equal 1, logger.records.count
    r = logger.records.first
    assert_equal 5, r.keys.count
    assert r[:created_at].present?
    assert r['__cluster__'].present?
    assert r['__database__'].present?
    assert r['__table__'].present?
  end

  test 'initialize records puts in the default fields' do
    logger = RedshiftLogger.new(records: [{a: 5}], table: 'sup', database: 'sup', cluster: 'sup')
    assert_equal 1, logger.records.count
    r = logger.records.first
    assert_equal 5, r.keys.count
    assert r[:created_at].present?
    assert r['__cluster__'].present?
    assert r['__database__'].present?
    assert r['__table__'].present?
  end
end
