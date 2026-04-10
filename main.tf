
provider "aws" {
  region = "us-east-1"
}
# --- 1. S3 BUCKETS ---
resource "aws_s3_bucket" "input" {
  bucket_prefix = "translate-input-"
}
resource "aws_s3_bucket" "output" {
  bucket_prefix = "translate-output-"
}

# --- 2. IAM ROLE & PERMISSIONS ---
resource "aws_iam_role" "lambda_role" {
  name = "translation_pipeline_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}
resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.input.arn}/*"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = "${aws_s3_bucket.output.arn}/*"
      },
      {
        Effect   = "Allow"
        Action   = ["translate:TranslateText", "logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "*"
      }
    ]
  })
}

# --- 3. LAMBDA FUNCTION ---
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "lambda_function.zip"
}
resource "aws_lambda_function" "translator" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "TextTranslator"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  environment {
    variables = {
      OUTPUT_BUCKET = aws_s3_bucket.output.id
    }
  }
}

# --- 4. S3 TRIGGER CONFIGURATION ---
resource "aws_lambda_permission" "allow_s3" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.translator.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.input.arn
}
resource "aws_s3_bucket_notification" "trigger" {
  bucket = aws_s3_bucket.input.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.translator.arn
    events              = ["s3:ObjectCreated:*"]
  }
  depends_on = [aws_lambda_permission.allow_s3]
}


