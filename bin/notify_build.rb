#!/usr/bin/env ruby

require 'httparty'

url = 'https://hooks.slack.com/services/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'
circle_tag = ENV['CIRCLE_TAG'] || 'unspecified'

body = {
  "text" => "Built `#{circle_tag}`. To deploy run ```\nmightydeploy --service <SERVICE_NAME> --images varys=sidekiq=nginx=#{circle_tag}\n```",
  "channel" => "#circle-ci",
  "username" => "deploy",
  "icon_emoji" => ":monkey_face:"
}

res = HTTParty.post(url, body: body.to_json, headers: { 'Content-type' => 'application/json' })
