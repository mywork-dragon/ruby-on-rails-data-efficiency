class MockRequest
  def uuid
    'value'
  end

  def request_method
    'GET'
  end

  def original_url
    'https://api.mightysignal.com/ios/app/123'
  end

  def query_parameters
    {
      'installed_sdk_id' => '1'
    }
  end

  def fullpath
    '/ios/app/123?installed_sdk_id=1'
  end
end
