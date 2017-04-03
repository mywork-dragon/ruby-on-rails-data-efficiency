require 'test_helper'

class WebsiteTest < ActiveSupport::TestCase

  test 'it sets the domain and match_string when creating websites' do
    w = Website.create!(url: 'https://www.something.google.com/en?q=something')
    assert_equal 'something.google.com', w.domain
    assert_equal 'something.google.com/en', w.match_string
  end

  test 'handles schemeless urls' do
    w = Website.create!(url: 'hello.com')
    assert_equal 'hello.com', w.domain
    assert_equal 'hello.com', w.match_string
  end

  test 'using import and specifying before_create populates fields' do
    rows = [Website.new(url: 'https://something.com/en')]
    rows.each { |row| row.run_callbacks(:create) { false } }
    Website.import rows
    assert_equal 'something.com', Website.first.domain
  end
end
