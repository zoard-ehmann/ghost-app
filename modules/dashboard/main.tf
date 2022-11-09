# INFO
# ------------------------------ #
# Not sure if the following policy is required...
# Probably NOT, but doesn't hurt
resource "aws_iam_policy" "this" {
  name        = var.dashboard_iam_policy_name
  description = "Allows logging"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams",
        "logs:CreateLogGroup",
        "logs:PutRetentionPolicy"
    ],
      "Resource": [
        "arn:aws:logs:*:*:*"
    ]
  }
 ]
}
EOF

  tags = {
    Name    = var.dashboard_iam_policy_name
    Project = var.project
  }
}
# ------------------------------ #

resource "aws_cloudwatch_dashboard" "ghost" {
  dashboard_name = var.cw_dashboard_name

  dashboard_body = <<EOF
{
  "widgets": [
    {
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/EC2",
            "CPUUtilization",
            "AutoScalingGroupName",
            "${var.asg_name}"
          ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "${var.region}",
        "title": "EC2 Average CPU Utilization"
      }
    },
    {
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/ECS",
            "CPUUtilization",
            "ServiceName",
            "${var.service_name}",
            "ClusterName",
            "${var.ecs_cluster_name}"
          ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "${var.region}",
        "title": "ECS Service CPU Utilization"
      }
    },
    {
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/ECS",
            "CPUUtilization",
            "ServiceName",
            "${var.service_name}",
            "ClusterName",
            "${var.ecs_cluster_name}"
          ]
        ],
        "period": 60,
        "stat": "SampleCount",
        "region": "${var.region}",
        "title": "ECS Running Tasks Count"
      }
    },
    {
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/EFS",
            "ClientConnections",
            "FileSystemId",
            "${var.efs_id}"
          ]
        ],
        "period": 300,
        "stat": "Sum",
        "region": "${var.region}",
        "title": "EFS Client Connections"
      }
    },
    {
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/EFS",
            "StorageBytes",
            "FileSystemId",
            "${var.efs_id}"
          ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "${var.region}",
        "title": "EFS Storage Bytes in Mb"
      }
    },
    {
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/RDS",
            "DatabaseConnections",
            "DBInstanceIdentifier",
            "${var.db_id}"
          ]
        ],
        "period": 300,
        "stat": "Sum",
        "region": "${var.region}",
        "title": "RDS Database Connections"
      }
    },
    {
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/RDS",
            "CPUUtilization",
            "DBInstanceIdentifier",
            "${var.db_id}"
          ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "${var.region}",
        "title": "RDS CPU Utilization"
      }
    },
    {
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/RDS",
            "ReadIOPS",
            "DBInstanceIdentifier",
            "${var.db_id}"
          ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "${var.region}",
        "title": "RDS Storage Read IOPS"
      }
    },
    {
      "type": "metric",
      "properties": {
        "metrics": [
          [
            "AWS/RDS",
            "WriteIOPS",
            "DBInstanceIdentifier",
            "${var.db_id}"
          ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "${var.region}",
        "title": "RDS Storage Write IOPS"
      }
    }
  ]
}
EOF
}
