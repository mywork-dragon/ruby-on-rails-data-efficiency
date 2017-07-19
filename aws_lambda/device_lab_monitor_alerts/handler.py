import json
import itertools
import os

from urllib2 import Request, urlopen

def slack_msg(metric, device_id, device_type, os_version, device_purpose, success):
    text = "Device Now Healthy" if success else "Device Failed Health Check"
    body = json.dumps({
      "text" : text,
      "channel" : "device-lab-monitor",
      "username" : "DeviceMonitor",
      "icon_emoji": ':marco:',
      "attachments": [
        {
            "fallback": text,
            "color": "#36a64f" if success else "#ff0000",
            "fields": [
                {
                    "title": "CheckType",
                    "value": metric,
                    "short": "true"
                },
                {
                    "title": "DeviceId",
                    "value": device_id,
                    "short": "true"
                },
                {
                    "title": "DeviceType",
                    "value": device_type,
                    "short": "true"
                },
                {
                    "title": "OSVersion",
                    "value": os_version,
                    "short": "true"
                },
                {
                    "title": "DevicePurpose",
                    "value": device_purpose,
                    "short": "true"
                }
            ]
        }
    ]
    })
    q = Request("https://hooks.slack.com/services/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", body, {'Content-Type': 'application/json'})
    f = urlopen(q)
    f.read()    



def update_dashboard(event, context):
    dashboard_host = os.environ['DASHBOARD_HOST']
    event_details = parse_event(event)
    body = json.dumps({
      "MetricName": event_details['MetricName'],
      "DeviceId": event_details['DeviceId'],
      "DeviceType": event_details['DeviceType'],
      "OSVersion": event_details['OSVersion'],
      "Status": event_details['AlarmState'],
      "DevicePurpose": event_details['DevicePurpose']
    })
    q = Request("{}/devices/status".format(dashboard_host), body, {'Content-Type': 'application/json'})
    f = urlopen(q)
    f.read()

def post_to_slack(event, context):
    event_details = parse_event(event)
    healthy = True if event_details['AlarmState'] == 'OK' else False
    slack_msg(event_details['MetricName'], event_details['DeviceId'], event_details['DeviceType'], event_details['OSVersion'], event_details['DevicePurpose'], healthy)

def parse_event(event):
    message = event['Records'][0]['Sns']['Message']
    message_dict = json.loads(message)
    alarm_state = message_dict['NewStateValue']
    event_details = message_dict['Trigger']
    metric_name = event_details['MetricName']
    device_id = next(itertools.ifilter(lambda x: x['name'] == 'DeviceId', event_details['Dimensions']))['value']
    device_type = next(itertools.ifilter(lambda x: x['name'] == 'DeviceType', event_details['Dimensions']))['value']
    os_version = next(itertools.ifilter(lambda x: x['name'] == 'OSVersion', event_details['Dimensions']))['value']
    device_purpose = get_device_purpose(device_id)
    return {
        "MetricName": metric_name, 
        "DeviceId": device_id,
        "DeviceType": device_type,
        "OSVersion": os_version,
        "AlarmState": alarm_state,
        "DevicePurpose": device_purpose
    }

def get_device_purpose(device_id):
    varys_api_host = os.environ['VARYS_API_ENDPOINT']
    varys_admin_key = os.environ['VARYS_SECRET']
    request = urlopen(Request("{}/ios_devices?access_token={}&id={}".format(varys_api_host, varys_admin_key, device_id)))
    result_object = json.load(request)
    return result_object[0]["purpose"]

if __name__ == "__main__":
    post_to_slack(None, {})
