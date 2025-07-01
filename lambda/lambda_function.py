import json
import boto3
import base64
import uuid
from PIL import Image
import io
import os

s3 = boto3.client('s3')
bucket_name = os.environ['BUCKET']

def lambda_handler(event, context):
    try:
        # Decode base64 image from API Gateway body
        body = json.loads(event['body'])
        image_data = base64.b64decode(body['image'])
        
        # Load and resize image
        image = Image.open(io.BytesIO(image_data))
        image_resized = image.resize((300, 300))

        # Save resized image to buffer
        buffer = io.BytesIO()
        image_resized.save(buffer, 'JPEG')
        buffer.seek(0)

        # Generate unique filename
        filename = f"{uuid.uuid4().hex}.jpg"

        # Upload to S3
        s3.put_object(
            Bucket=bucket_name,
            Key=f"resized/{filename}",
            Body=buffer,
            ContentType='image/jpeg'
        )

        return {
            'statusCode': 200,
            'body': json.dumps({"message": "Image resized and uploaded", "file": f"resized/{filename}"})
        }

    except Exception as e:
        print("Error occurred:", str(e))
        return {
            'statusCode': 500,
            'body': json.dumps({"error": str(e)})
        }
