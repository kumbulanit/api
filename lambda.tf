resource "aws_iam_role_policy" "ingestpolicy" {
  name = "ingest"
  role = aws_iam_role.lambda.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:Start*",
          "ec2:Stop*",
          "ec2:Describe*"
        ],
        Resource = "*"
      }
    ]
  })
}
resource "aws_iam_role" "lambda" {
  name = "lambda-function-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}
resource "archive_file" "lambda_file" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "lambda_function.zip"
}
resource "aws_lambda_function" "lambda_ingest_function" {
  filename      = "lambda_function.zip"
  function_name = "lambda_function"
  role          = aws_iam_role.lambda.arn
  handler       = "lambda_function.lambda_handler"
  #source_code_hash = filebase64sha256("main.zip")

  runtime = "python3.9"
}