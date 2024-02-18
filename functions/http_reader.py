import boto3
from botocore.exceptions import ClientError
import os

# Initialize the S3 client
s3 = boto3.client('s3')

# Your S3 bucket name
bucket_name = os.environ['BUCKET_NAME']

def lambda_handler(event, context):
    try:
        # Initialize paginator for handling potentially truncated responses
        paginator = s3.get_paginator('list_objects_v2')
        pages = paginator.paginate(Bucket=bucket_name, Prefix='')

        latest_object_key = None
        latest_last_modified = None

        # Iterate over each page of objects
        for page in pages:
            if 'Contents' in page:
                for obj in page['Contents']:
                    if latest_last_modified is None or obj['LastModified'] > latest_last_modified:
                        latest_last_modified = obj['LastModified']
                        latest_object_key = obj['Key']

        # Check if we found an object
        if latest_object_key:
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
