require 'lib/hotstore/domain_data_hot_store_schema'
require 'lib/hotstore/sdk_hot_store_schema'
require 'lib/hotstore/publisher_hot_store_schema'
require 'lib/hotstore/app_hot_store_schema'

class HotStoreSchemaTestBase < ActiveSupport::TestCase
  include ::AppHotStoreSchema
  include ::PublisherHotStoreSchema
  include ::SdkHotStoreSchema
  include ::DomainDataHotStoreSchema

  ##
  #
  # This unit test base class to verify the schema that is written
  # to the HotStore. An example of a schema is in app_hot_store_schema.rb.
  # The validate function ensures that all fields, and only those fields
  # listed in the schema are present in the entry argument.
  #
  def validate(schema, entry, prev_key: nil)
    if schema.is_a? Array
      validate_raw(Array, entry)
      return entry.each { |el| validate_raw(schema[0], el) }
    elsif not schema.is_a? Hash
      validate_raw(schema, entry, key: prev_key)
      return
    end

    entry.keys.each do |key|
      assert_includes schema.keys, key, "Extra attribute #{key} written in #{prev_key || "root object"}"
    end

    schema.each do |key, expected_type|
      if expected_type.is_a? Array
        entry[key].each do |el|
          validate(expected_type[0], el, prev_key: key)
        end
      elsif expected_type == Hash or expected_type.is_a? Hash
        validate(expected_type, entry[key], prev_key: key)
      else
        validate_raw(expected_type, entry[key], key: key)
      end
    end
  end

private

  def validate_raw(expected_type, value, key: nil)
    if expected_type == TrueClass or expected_type == FalseClass
      assert (value == true or value == false)
    else
      assert_instance_of expected_type, value, "#{key} is not of expected type: #{expected_type}"
    end
  end

end
