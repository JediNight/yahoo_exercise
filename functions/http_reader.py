import boto3
import os
from botocore.exceptions import ClientError

# Initialize the S3 client
s3 = boto3.client('s3')
kms = boto3.client('kms')


# Your S3 bucket name
bucket_name = os.environ['BUCKET_NAME']
kms_key_arn = os.environ['KMS_KEY_ARN']

def lambda_handler(event, context):
    # Get the list of objects in the bucket
    try:
        # List objects in the S3 bucket, sorted by last modified date
        response = s3.list_objects_v2(
            Bucket=bucket_name,
            Prefix='',  # You can specify a prefix if your objects are in a folder
            MaxKeys=1
        )
        
        # Check if there are any objects in the bucket
        if 'Contents' in response:
            all_objects = sorted(response['Contents'], key=lambda obj: obj['LastModified'], reverse=True)
            
            # Get the key of the most recent object
            latest_object_key = all_objects[0]['Key']
            
            # Get the content of the most recent object
            latest_object = s3.get_object(Bucket=bucket_name, Key=latest_object_key)
            latest_content = latest_object['Body'].read().decode('utf-8')
            
            # Return the content of the latest object
            return {
                'statusCode': 200,
                'body': latest_content,
                'headers': {
                    'Content-Type': 'text/plain'
                }
            }
        else:
            return {
                'statusCode': 404,
                'body': 'No objects found in bucket',
                'headers': {
                    'Content-Type': 'text/plain'
                }
            }

    except ClientError as e:
        return {
            'statusCode': e.response['ResponseMetadata']['HTTPStatusCode'],
            'body': str(e),
            'headers': {
                'Content-Type': 'text/plain'
            }
        }
