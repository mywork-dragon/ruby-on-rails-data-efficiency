# Class to send requests to a device that is running the WebDriverAgentClient
# Wraps the WebDriver API to allow for more convenient interaction with the
# device.

class WebDriverAgentClient

  class WebDriverAgentError < RuntimeError; end

  #### Public Functions


  #### Initialization Functions

  def initialize(server_ip, port)
    @server_ip = server_ip
    @port = port
    @http = Net::HTTP.new(@server_ip, @port)
  end

  # You can either use this method to start the web driver agent server or start it
  # yourself. This method simply starts the process and sleeps for 15 seconds to allow
  # the service to start. It doesn't monitor any out puts of the service.
  def start_remote(device_id, web_driver_agent_path)
    spawn("xcodebuild -project WebDriverAgent.xcodeproj -scheme WebDriverAgentRunner -destination 'platform=iOS,id=#{device_id}' test", :chdir => "#{web_driver_agent_path}")
    sleep 20
  end

  def start_session(bundle_id)
    uri = URI.parse("http://#{@server_ip}:#{@port}/session")
    request = Net::HTTP::Post.new(uri.request_uri, {"Content-Type" => "application/json"})
    request.body = JSON.dump({
      "desiredCapabilities" => {
        "bundleId" => bundle_id
      }
    })
    response = @http.request(request)
    response = JSON.parse(response.body)
    raise WebDriverAgentError, "SessionId not found." if not response["sessionId"]
    puts response["sessionId"]
    @session_id = response["sessionId"]
  end

  #### Query Functions

  def get_element_id(element_type, value: nil, label: nil, element_index: 0)
    raise WebDriverAgentError, "Must supply one of label, value or id params." if label.nil? and value.nil?

    return element_with_label!(element_type, label, element_index: element_index) if label
    return element_with_value!(element_type, label, element_index: element_index) if value
  end

  def element_exists?(element_type, label)
    begin
      element_with_label!(element_type, label)
      return true
    rescue WebDriverAgentError => e
      return false
    end
  end

  def get_element_attribute(element_id, attribute: 'name')
    raise WebDriverAgentError, "Session not started" if not @session_id
    uri = URI.parse("http://#{@server_ip}:#{@port}/session/#{@session_id}/element/#{element_id}/attribute/#{attribute}")
    request = Net::HTTP::Get.new(uri.request_uri, {"Content-Type" => "application/json"})
    response = @http.request(request)
    response = JSON.parse(response.body)
    return response["value"]
  end

  def elements_by_class_chain(chain)
    raise WebDriverAgentError, "Session not started" if not @session_id
    uri = URI.parse("http://#{@server_ip}:#{@port}/session/#{@session_id}/elements")
    request = Net::HTTP::Post.new(uri.request_uri, {"Content-Type" => "application/json"})
    request.body = JSON.dump({
      "using" => "class chain",
      "value" => chain
    })
    response = @http.request(request)
    response = JSON.parse(response.body)
    raise WebDriverAgentError, "Search field with chain #{chain} not found." if response["value"].empty?
    return response["value"].map do |el_data|
      el_data["ELEMENT"]
    end
  end

  def elements_by_class_name(class_name)
    raise WebDriverAgentError, "Session not started" if not @session_id
    uri = URI.parse("http://#{@server_ip}:#{@port}/session/#{@session_id}/elements")
    request = Net::HTTP::Post.new(uri.request_uri, {"Content-Type" => "application/json"})
    request.body = JSON.dump({
      "using" => "class name",
      "value" => "XCUIElementType#{class_name}"
    })
    response = @http.request(request)
    response = JSON.parse(response.body)
    raise WebDriverAgentError, "Text field with value #{value} not found." if response["value"].empty?
    return response["value"].map do |el_data|
      el_data["ELEMENT"]
    end
  end

  # First element in the array returned will be the element itself.
  def get_element_children(id)
    raise WebDriverAgentError, "Session not started" if not @session_id
    uri = URI.parse("http://#{@server_ip}:#{@port}/session/#{@session_id}/element/#{id}/elements")
    request = Net::HTTP::Post.new(uri.request_uri, {"Content-Type" => "application/json"})
    request.body = JSON.dump({
      "using" => "predicate string",
      "value" => "wdVisible==1"
    })
    response = @http.request(request)
    response = JSON.parse(response.body)
    return response["value"].map do |child_data|
      child_data["ELEMENT"]
    end
  end

  def is_switch_on?(id: nil, switch_label: nil)
    raise WebDriverAgentError, "Must supply one of switch_label, value or id params." if switch_label.nil? and id.nil?
    
    switch_id = id
    switch_id = element_with_label!('Switch', switch_label) if switch_id.nil?

    get_element_attribute(switch_id, attribute: 'value') == "1"
  end

  #### Interaction Functions

  def tap_element(label: nil, id: nil, element_type: "Button", wait_time: 5, element_index: 0)
    raise WebDriverAgentError, "Must supply label or id" if label.nil? and id.nil?

    wait_time.times do
      begin
        element_id = id
        element_id = element_with_label!(element_type, label, element_index: element_index) if id.nil?
        tap_element_with_id(element_id)
        return
      rescue WebDriverAgentClient::WebDriverAgentError => e
        sleep 1
      end
    end
    raise WebDriverAgentError, "Didn't find button with label #{label} after waiting #{wait_time} seconds"
  end

  def scroll_to_element(id: nil, label: nil, element_type: "StaticText", element_index: 0)
    raise WebDriverAgentError, "Session not started" if not @session_id
    raise WebDriverAgentError, "Must supply either label or id param" if id.nil? and label.nil?

    element_id = id
    element_id = element_with_label!(element_type, label, element_index: element_index) if element_id.nil?

    uri = URI.parse("http://#{@server_ip}:#{@port}/session/#{@session_id}/wda/element/#{element_id}/scroll")
    request = Net::HTTP::Post.new(uri.request_uri, {"Content-Type" => "application/json"})
    request.body = JSON.dump({
      "toVisible" => "true"
    })
    response = @http.request(request)
    response = JSON.parse(response.body)
    raise WebDriverAgentError, "Error scolling to element with label #{label}." if response["status"] != 0
    return response["status"]
  end

  def type_into_field(keys, label: nil, value: nil, id: nil, element_type: "SearchField", clear_first: true, element_index: 0)
    raise WebDriverAgentError, "Must supply one of label, value or id params." if label.nil? and id.nil? and value.nil?

    field_id = id
    field_id = element_with_label!(element_type, label, element_index: element_index) if field_id.nil? and not label.nil?
    field_id = element_with_value!(element_type, value, element_index: element_index) if field_id.nil? and not value.nil?

    raise WebDriverAgentError, "Unable to find field with given params." if field_id.nil?

    clear_text!(field_id) if clear_first
    send_keys!(field_id, keys)
  end


  #### Private Helper Functions

  def tap_element_with_id(id)
    raise WebDriverAgentError, "Session not started" if not @session_id
    uri = URI.parse("http://#{@server_ip}:#{@port}/session/#{@session_id}/element/#{id}/click")
    request = Net::HTTP::Post.new(uri.request_uri, {"Content-Type" => "application/json"})
    response = @http.request(request)
    response = JSON.parse(response.body)
    raise WebDriverAgentError, "Error tapping button with id #{id}." if not response["status"] == 0
    return response["status"]
  end

  def element_with_label!(element_type, label, element_index: 0)
    raise WebDriverAgentError, "Session not started" if not @session_id
    uri = URI.parse("http://#{@server_ip}:#{@port}/session/#{@session_id}/elements")
    request = Net::HTTP::Post.new(uri.request_uri, {"Content-Type" => "application/json"})
    request.body = JSON.dump({
      "using" => "class chain",
      "value" => "**/XCUIElementType#{element_type}[`label == \"#{label}\"`]"
    })
    response = @http.request(request)
    response = JSON.parse(response.body)
    raise WebDriverAgentError, "Search field with label #{label} not found." if response["value"].empty?
    return response["value"][element_index]["ELEMENT"]
  end

  def element_with_value!(element_type, value, element_index: 0)
    raise WebDriverAgentError, "Session not started" if not @session_id
    uri = URI.parse("http://#{@server_ip}:#{@port}/session/#{@session_id}/elements")
    request = Net::HTTP::Post.new(uri.request_uri, {"Content-Type" => "application/json"})
    request.body = JSON.dump({
      "using" => "class chain",
      "value" => "**/XCUIElementType#{element_type}[`value == \"#{value}\"`]"
    })
    response = @http.request(request)
    response = JSON.parse(response.body)
    raise WebDriverAgentError, "Search field with value #{value} not found." if response["value"].empty?
    return response["value"][element_index]["ELEMENT"]
  end

  def send_keys!(element_id, keys)
    raise WebDriverAgentError, "Session not started" if not @session_id
    uri = URI.parse("http://#{@server_ip}:#{@port}/session/#{@session_id}/element/#{element_id}/value")
    request = Net::HTTP::Post.new(uri.request_uri, {"Content-Type" => "application/json"})
    request.body = JSON.dump({
      "value" => keys.split("")
    })
    response = @http.request(request)
    response = JSON.parse(response.body)
    raise WebDriverAgentError, "Error sending keys to #{element_id}." if not response["status"] == 0
    return response["status"]
  end

  def clear_text!(element_id) 
    raise WebDriverAgentError, "Session not started" if not @session_id
    uri = URI.parse("http://#{@server_ip}:#{@port}/session/#{@session_id}/element/#{element_id}/clear")
    request = Net::HTTP::Post.new(uri.request_uri, {"Content-Type" => "application/json"})
    response = @http.request(request)
    response = JSON.parse(response.body)
    raise WebDriverAgentError, "Error clearing element #{element_id}." if not response["status"] == 0
    return response["status"]
  end

end