import json
import itertools
import os
import requests

VARYS_API_ENDPOINT = os.environ['VARYS_API_ENDPOINT']
VARYS_SECRET = os.environ['VARYS_SECRET']
DASHBOARD_HOST = os.environ['DASHBOARD_HOST']

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
    requests.post("https://hooks.slack.com/services/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", data=body, headers={'Content-Type': 'application/json'})

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

def set_device_enabled(device_id, healthy):
    params = {
        "access_token": VARYS_SECRET,
        "id": device_id
    }
    if healthy:
        requests.put("{}/ios_devices/enable".format(VARYS_API_ENDPOINT), params=params, headers={'Accept': 'application/json'})
    else:
        requests.put("{}/ios_devices/disable".format(VARYS_API_ENDPOINT), params=params, headers={'Accept': 'application/json'})

def get_device_purpose(device_id):
    params = {
        "access_token": VARYS_SECRET,
        "id": device_id
    }
    request = requests.get("{}/ios_devices".format(VARYS_API_ENDPOINT), params=params)
    result_object = request.json()
    return result_object[0]["purpose"]

def post_event_to_dashboard(event_details):
    body = json.dumps({
      "MetricName": event_details['MetricName'],
      "DeviceId": event_details['DeviceId'],
      "DeviceType": event_details['DeviceType'],
      "OSVersion": event_details['OSVersion'],
      "Status": event_details['AlarmState'],
      "DevicePurpose": event_details['DevicePurpose']
    })
    requests.post("{}/devices/status".format(DASHBOARD_HOST), data=body, headers={'Content-Type': 'application/json'})

# Lambda function handler to set device status in db and notify slack
def handle_device_event(event, context):
    event_details = parse_event(event)
    healthy = True if event_details['AlarmState'] == 'OK' else False
    set_device_enabled(event_details['DeviceId'], healthy)
    slack_msg(event_details['MetricName'], event_details['DeviceId'], event_details['DeviceType'], event_details['OSVersion'], event_details['DevicePurpose'], healthy)
    post_event_to_dashboard(event_details)

if __name__ == "__main__":
    handle_device_event(None, {})
