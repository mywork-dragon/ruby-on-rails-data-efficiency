#!/usr/bin/env ruby

require 'net/http'
require "uri"
require 'json'


url = 'https://hooks.slack.com/services/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'
circle_tag = ENV['CIRCLE_TAG'] || 'unspecified'

body = {
  "text" => "Built `#{circle_tag}`. To deploy run ```\nmightydeploy --service <SERVICE_NAME> --images varys=sidekiq=nginx=#{circle_tag}\n```",
  "channel" => "#circle-ci",
  "username" => "deploy",
  "icon_emoji" => ":monkey_face:"
}

uri = URI.parse(url)

header = {"Content-Type" => "application/json"}

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
request = Net::HTTP::Post.new(uri.request_uri, header)
request.body = JSON.dump body

response = http.request(request)
