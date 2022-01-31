resource "aws_iam_role" "ingest_user" {
  name = "tfg-ingest"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "s3.amazonaws.com"
        }
      },
    ]
  })
}
resource "aws_iam_policy" "ingest_policy" {
  name = "ingest-policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:*",
          "s3-object-lambda:*"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ingest_iam_policy" {
  role       = aws_iam_role.ingest_user.name
  policy_arn = aws_iam_policy.ingest_policy.arn

}