module AppAttributeChecker

  # Whether all the attributes pass their requirements
  # @author Jason Lew
  # @param attributes The attributes scraped
  # @param attributes_expexcted A Hash with Lambdas as keys 
  def all_attributes_pass?(attributes:, attributes_expected:)
    ret = true

    attributes_expected.each do |expected_attribute_key, expected_attribute_value|
      attribute_value = attributes[expected_attribute_key]

      pass = attributes_expected[expected_attribute_key].call(attribute_value)

      if pass
        puts "#{expected_attribute_key}: PASS".green
      else
        ret = false
        puts "#{expected_attribute_key}: FAIL".red
        puts "#{attribute_value}".purple
      end

      puts ""

      end

    ret
  end

end