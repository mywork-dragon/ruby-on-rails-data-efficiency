import urllib
import boto3
import json
import time
import urllib2
from urllib2 import Request, urlopen

client = boto3.client('ecs')

def list_running_task_arns(cluster, service):
    response = client.list_tasks(
        cluster=cluster,
        serviceName=service,
        desiredStatus='RUNNING'
    )
    return response['taskArns']

def kill_tasks(cluster, service, reason, delay):
    print "kill called with delay", delay
    for task in list_running_task_arns(cluster, service):
        response = client.stop_task(
            cluster=cluster,
            task=task,
            reason=reason
        )
        print "sleep", delay
        time.sleep(delay)

def slack_msg(text, channel, username):
    body = json.dumps({
      "text" : text,
      "channel" : channel,
      "username" : username,
      "icon_emoji": ':bb8:'
    })
    q = Request("https://hooks.slack.com/services/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", body, {'Content-Type': 'application/json'})
    f = urllib2.urlopen(q)
    f.read()

def hello(event, context):
    channel = '#jobs'
    username = 'auto-instant-classification'
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.unquote_plus(event['Records'][0]['s3']['object']['key'].encode('utf8'))

    services = [('ANDROID_CLASSIFICATION', 'spot', 0), ('ANDROID_MASS_SCAN', 'spot', 0), ('ANDROID_LIVE_SCAN', 'default', 5)]

    slack_msg("Android classification model updated. Rolling services...", channel, username)

    for service, cluster, delay in services:
        kill_tasks(cluster, service, 'updated model at s3://{}/{}'.format(bucket, key), delay)
        slack_msg("Rolled {} on cluster {}.".format(service, cluster), channel, username)

    
