output "s3_bucket_id" {
  value = aws_s3_bucket.image_bucket.id
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.image_bucket.arn
}

output "lambda_function_arn" {
  value = aws_lambda_function.image_resizer.arn
}
