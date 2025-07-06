# Serverless App with Terraform, AWS Lambda, API Gateway & S3

This project demonstrates how to build and deploy a serverless application on AWS using **Terraform** for infrastructure provisioning. It leverages **AWS Lambda** for compute, **API Gateway** for exposing endpoints, and **S3** for storage.

## Stack

- **AWS Lambda** – Executes the image resizing logic
- **API Gateway (HTTP API)** – Receives image POST requests
- **S3** – Stores resized images
- **Terraform** – Manages the infrastructure as code
- **Python (Pillow)** – Handles image resizing inside Lambda

## Project Structure

```
├── lambda/
│ ├── lambda_function.py
│ └── Pillow package
├── terraform/
│ ├── main.tf
│ ├── outputs.tf
│ ├── providers.tf
│ ├── variables.tf
│ ├── terraform.tfvars # Ignored in git
│ └── .gitignore
└── README.md
```

## How It Works

1. User sends a base64 image in a POST request to `/upload` via API Gateway.
2. API Gateway triggers a Lambda function.
3. Lambda:
   - Resizes the image to 300x300 using Pillow
   - Stores it in `resized/` folder of the S3 bucket
4. Lambda returns a JSON with the image path.

## Prerequisites
- Python 3.x
- Terraform
- An AWS account
- Optional: EC2 instance with IAM role
  
## Setup

### 1. Secure AWS Credentials

As a best practice, I used a **remote EC2 VM** with an **attached instance role**, instead of exporting AWS credentials manually. The instance role had just the required permissions:

- `AmazonS3FullAccess`
- `AWSLambda_FullAccess`
- `AmazonAPIGatewayAdministrator`
- `IAMFullAccess`

This eliminates the need to store AWS credentials in the environment.

### 2. Prepare the Project

```bash
mkdir lambda terraform
touch lambda/lambda_function.py terraform/main.tf terraform/outputs.tf terraform/variables.tf terraform/providers.tf terraform/terraform.tfvars
```
### 3. Install Pillow and Package the Lambda
Navigate to the lambda/ folder and install the Pillow package:

`pip install pillow -t .`

Then zip everything (recursively) and move it to the terraform/ folder:

`zip -r ../terraform/lambda.zip .`

⚠️ Note for Ubuntu Users:
Since AWS Lambda runs on Amazon Linux, it’s better to package dependencies inside an Amazon Linux container to avoid runtime issues.
For example:

```
docker run -v "$PWD":/var/task lambci/lambda:build-python3.8 pip install pillow -t .
zip -r ../terraform/lambda.zip .
```
### 4. Deploy with Terraform
Navigate to the terraform/ directory and initialize Terraform:

```
terraform init
terraform plan
terraform apply --auto-approve
```

After a few minutes, your Lambda function, API Gateway, and S3 bucket should be ready.

### 5. Test with curl
Download an image, encode it to base64, and send a request:

```
curl -o cat.jpg https://images.unsplash.com/photo-1592194996308-7b43878e84a6?w=600
base64 cat.jpg > encoded.txt
export BASE64_IMAGE=$(cat encoded.txt | tr -d '\n')

curl -X POST https://<your-api-url>/upload \
  -H "Content-Type: application/json" \
  -d "{\"image\": \"${BASE64_IMAGE}\"}"
```
### 6. Check S3 for Uploaded Image
Go to your S3 console, the resized image should be inside the resized/ folder.

To make the image publicly viewable in a browser:

- Disable “Block all public access” for the bucket.

- Add a bucket policy like this before uploading any files:

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowPublicRead",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::<your-bucket-name>/*"
    }
  ]
}
```
Note: If the bucket policy is added after the file upload, the object may still be private.


## Improvements
1. Add a frontend interface to let users upload and view resized images
2. Improve error handling and response messages
3. Generate pre-signed URLs for secure image access
4. Add GitHub Actions to automate deployment via CI/C
