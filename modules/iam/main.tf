resource "aws_iam_role" "this" {
  name = var.iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name    = var.iam_role_name
    Project = var.project
  }
}

resource "aws_iam_policy" "this" {
  name        = var.iam_policy_name
  description = "Allows EC2 Describe*, EFS DescribeFS, EFS ClientMount & ClientWrite"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*",
        "elasticfilesystem:ClientMount",
        "elasticfilesystem:ClientWrite",
        "elasticfilesystem:DescribeFileSystems",
        "ssm:GetParameter*",
        "secretsmanager:GetSecretValue",
        "kms:Decrypt"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF

  tags = {
    Name    = var.iam_policy_name
    Project = var.project
  }
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_iam_instance_profile" "this" {
  name = var.iam_profile_name
  role = aws_iam_role.this.name

  tags = {
    Name    = var.iam_profile_name
    Project = var.project
  }
}
