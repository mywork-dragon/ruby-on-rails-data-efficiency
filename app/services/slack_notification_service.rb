class SlackNotificationService
  
  class << self
    def test
    
      text = "Hello SLACK!"
    
      json = {text: text}.to_json
      HTTParty.post('https://hooks.slack.com/services/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', body: json)
    end
    
    def done(status, options)
      text = status.data
    
      json = {text: text}.to_json
      HTTParty.post('https://hooks.slack.com/services/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', body: json)
    end
    
  end
  
end