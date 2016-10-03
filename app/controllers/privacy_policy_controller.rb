class PrivacyPolicyController < ApplicationController

  def fb_recruiting
    render '/privacy_policy/fb_recruiting.txt', layout: false, content_type: 'text/plain'
  end

end
