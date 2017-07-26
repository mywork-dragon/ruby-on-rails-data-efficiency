import json, boto3

ecs = boto3.client('ecs')

def process(event, context):
    records = event['Records']
    tasks = [load(r) for r in records]
    return {'status': 'ok', 'task_ids': [t['taskArn'] for t in tasks]}

def load(record):
    key = record['s3']['object']['key']
    bucket = record['s3']['bucket']['name']
    res = ecs.run_task(
            cluster='spot',
            taskDefinition='arn:aws:ecs:us-east-1:250424072945:task-definition/redshift_loader',
            overrides={
                'containerOverrides': [
                    {
                        'name': 'app',
                        'command': [
                            'python',
                            '-u',
                            '-m',
                            'mightylib.persistence.db.redshift',
                            '--data-format',
                            'json_concat_gzip',
                            '--s3-bucket',
                            bucket,
                            '--s3-key',
                            key
                        ]
                    }
                ]},
            count=1,
            startedBy='redshift-loading-lambda')
    return res['tasks'][0]

# if __name__ == '__main__':
#     event = {
#       "Records": [
#         {
#           "eventVersion": "2.0",
#           "eventTime": "1970-01-01T00:00:00.000Z",
#           "requestParameters": {
#             "sourceIPAddress": "127.0.0.1"
#           },
#           "s3": {
#             "configurationId": "testConfigRule",
#             "object": {
#               "eTag": "0123456789abcdef0123456789abcdef",
#               "sequencer": "0A1B2C3D4E5F678901",
#               "key": "test_data",
#               "size": 1024
#             },
#             "bucket": {
#               "arn": 'nothing',
#               "name": "ms-scratch",
#               "ownerIdentity": {
#                 "principalId": "EXAMPLE"
#               }
#             },
#             "s3SchemaVersion": "1.0"
#           },
#           "responseElements": {
#             "x-amz-id-2": "EXAMPLE123/5678abcdefghijklambdaisawesome/mnopqrstuvwxyzABCDEFGH",
#             "x-amz-request-id": "EXAMPLE123456789"
#           },
#           "awsRegion": "us-east-1",
#           "eventName": "ObjectCreated:Put",
#           "userIdentity": {
#             "principalId": "EXAMPLE"
#           },
#           "eventSource": "aws:s3"
#         }
#       ]
#     }
#     print process(event, None)
