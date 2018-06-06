#!/usr/bin/env python

import os, json
import urllib2

url = 'https://hooks.slack.com/services/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'
circle_tag = os.environ.get('CIRCLE_TAG', 'unspecified')

data = json.dumps({
  'text': "Built varys `{}`. To deploy run ```\nmightydeploy --service <SERVICE_NAME> --images varys=sidekiq=nginx={}\n```".format(circle_tag, circle_tag),
  'channel': '#circle-ci',
  'username': 'deploy',
  'icon_emoji': ':monkey_face:'})

request = urllib2.Request(
    url,
    data=data,
    headers={'Content-Type': 'application/json'})


response = urllib2.urlopen(request)
res = response.read()
print res
