import boto3

DEVICE_ALARM_PREFIXES = [ 'DEVICE_LAB_IOS_SSHAccess_', 'DEVICE_LAB_IOS_InternetAccess_' ]

class DeviceAlertsCloudWatchClient:
    
    def __init__(self):
        self.__cloud_watch_client = boto3.client('cloudwatch')

    def device_alarms_okay(self, device_id):
        device_alarms_response = self.__cloud_watch_client.describe_alarms(
            AlarmNames=map(lambda x: x + str(device_id), DEVICE_ALARM_PREFIXES),
            MaxRecords=len(DEVICE_ALARM_PREFIXES)
        )

        for device_alarm in device_alarms_response['MetricAlarms']:
            if device_alarm['StateValue'] != 'OK':
                return False

        return True