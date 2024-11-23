output "s3_bucket_id" {
  value = module.s3-bucket.s3_bucket_id
}

output "s3_bucket_arn" {
  value = module.s3-bucket.s3_bucket_arn
}


output "lambda_function_arn" {
  value = module.lambda.lambda_function_arn
}
