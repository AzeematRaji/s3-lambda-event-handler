# Create S3 Bucket using the S3 module
module "s3-bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.2.2"

  bucket        = var.bucket_name
  
}

  
# Add folders (objects) to the S3 bucket
resource "aws_s3_object" "test-stage" {
  bucket = module.s3-bucket.s3_bucket_id
  key    = "test-stage/"
}

resource "aws_s3_object" "prod-stage" {
  bucket = module.s3-bucket.s3_bucket_id
  key    = "prod-stage/"
}

# Create Lambda Function using the AWS Lambda module
module "lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.15.0"

  function_name = "s3-event-handler"
  handler       = "lambda-function.lambda_handler"
  runtime       = "python3.12"

  source_path = "/home/azeemah/lambda-function/lambda-function.py" 

  environment_variables = {
    TARGET_FOLDER = "prod-stage/"
  }

  attach_policy_json = true

  policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:DeleteObject"]
        Resource = "arn:aws:s3:::${var.bucket_name}/test-stage/*" # Access to source folder
      },
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = "arn:aws:s3:::${var.bucket_name}/prod-stage/*" # Access to destination folder
      }
    ]
  })

}

# Add S3 bucket notification to trigger Lambda on new object in test-stage
resource "aws_s3_bucket_notification" "lambda_trigger" {
  bucket = module.s3-bucket.s3_bucket_id

  lambda_function {
    lambda_function_arn = module.lambda.lambda_function_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "test-stage/"
  }
}

# Allow S3 bucket to trigger Lambda
resource "aws_lambda_permission" "s3_trigger" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.lambda_function_name
  principal     = "s3.amazonaws.com"
  source_arn    = module.s3-bucket.s3_bucket_arn
}





