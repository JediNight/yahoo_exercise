import boto3
from datetime import datetime
import os

bucket_name = os.environ['BUCKET_NAME']
kms_key = os.environ['KMS_KEY_ARN']
s3 = boto3.client('s3')


def lambda_handler(event, context):

    current_time = datetime.utcnow().strftime('%Y-%m-%dT%H-%M-%SZ')
    content = f'The current timestamp is: {current_time}'
    file_name = f'timestamps/timestamp_{current_time}.txt'
    
    try:
        s3.put_object(Bucket=bucket_name, Key=file_name, Body=content)
        print(f'Successfully uploaded {file_name} to {bucket_name}.')
        return {
            'statusCode': 200,
            'body': f'Successfully uploaded {file_name} to {bucket_name}.'
        }
    except Exception as e:
        print(f'Error uploading file: {str(e)}')
        return {
            'statusCode': 500,
            'body': f'Error uploading file: {str(e)}'
        }
