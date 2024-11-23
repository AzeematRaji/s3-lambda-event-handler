import boto3
import os

# Initialize the S3 client
s3_client = boto3.client('s3')

def lambda_handler(event, context):
    # Log the event for debugging
    print("Event:", event)
    
    # Loop through each record in the event
    for record in event['Records']:
        # Get the bucket name and object key from the event
        bucket_name = record['s3']['bucket']['name']
        source_key = record['s3']['object']['key']
        
        # Skip if the event is triggered on folders
        if source_key.endswith('/'):
            print(f"Skipping folder key: {source_key}")
            continue
        
        # Define the destination key using the environment variable or default
        destination_folder = os.getenv('TARGET_FOLDER', 'prod-stage/')  
        destination_key = f"{destination_folder}{source_key.split('/')[-1]}"
        
        try:
            # Copy the file to the destination folder
            print(f"Copying {source_key} to {destination_key}...")
            s3_client.copy_object(
                Bucket=bucket_name,
                CopySource={'Bucket': bucket_name, 'Key': source_key},
                Key=destination_key
            )
            
            # Delete the original file from the source folder
            print(f"Deleting original file: {source_key}...")
            s3_client.delete_object(
                Bucket=bucket_name,
                Key=source_key
            )
            
            print(f"File moved successfully: {source_key} -> {destination_key}")
        except Exception as e:
            print(f"Error processing file {source_key}: {str(e)}")
