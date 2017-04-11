import urllib
import boto3
import simplejson as json
import time
import math
import urllib2
from urllib2 import Request, urlopen

from mightylib.persistence.kv.s3 import S3Dict
from mightylib.monitoring.metrics import cw_report_metric

client = boto3.client('ecs')

processed_set = S3Dict(bucket='ms-ecs-task-statuses', region='us-east-1')

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


def check_ecs_tasks(event, context):
    for cluster in client.list_clusters()['clusterArns']:
        tasks = []
        for service in client.list_services(cluster=cluster)['serviceArns']:
            for task in client.list_tasks(cluster=cluster, serviceName=service, desiredStatus='STOPPED')['taskArns']:
                tasks.append(task)
        if tasks:
            n = int(math.ceil(len(tasks) / 100.0))
            for i in range(0, n):
                task_chunk = tasks[i*n:i*n+n]
                for task in client.describe_tasks(cluster=cluster, tasks=task_chunk)['tasks']:
                    if task['taskArn'] not in processed_set:
                        for container in task['containers']:
                            if 'reason' in container and 'OutOfMemoryError' in container['reason']:
                                # Handle OOM here.
                                if 'group' in task:
                                    msg = 'Task: {} (ecs service) exited due to OOM'.format(task['group'])
                                    cw_report_metric(task['group'].split(':')[1], 'OOM', value=1, unit = 'Count')
                                    cw_report_metric('[all_ecs_services]', 'OOM', value=1, unit = 'Count')
                                else:
                                    msg = 'Task: {} (one off) exited due to OOM'.format(task['taskDefinitionArn'])
                                    cw_report_metric('[ecs_one_off_tasks]', 'OOM', value=1, unit = 'Count')
                                print msg
                                slack_msg(msg, 'automated-alerts', 'Mr. Memory Inspector') 
                            elif 'reason' in container:
                                # Just log the stopped container.
                                msg = "Task: {} stopped due to {}".format(task['taskDefinitionArn'], container['reason'])
                                print msg
                                slack_msg(msg, 'ecs', 'Mr. Memory Inspector')

                            processed_set[task['taskArn']] = 'processed'

if __name__ == "__main__":
    check_ecs_tasks(None, {})
