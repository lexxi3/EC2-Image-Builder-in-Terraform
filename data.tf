# Declare data resources
data "aws_security_group" "this" {
  id = "sg-0c4d310c5a506f77d"
}
data "aws_subnet" "this" {
  id = "subnet-0a9200e72351b3fc4"
}
data "aws_partition" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "example" {
  statement {
    effect = "Allow"

    actions = [
      "imagebuilder:*"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "sns:ListTopics"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "sns:Publish"
    ]

    resources = ["arn:aws:sns:*:*:*imagebuilder*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "license-manager:ListLicenseConfigurations",
      "license-manager:ListLicenseSpecificationsForResource"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "iam:GetRole"
    ]

    resources = ["arn:aws:iam::*:role/aws-service-role/imagebuilder.amazonaws.com/AWSServiceRoleForImageBuilder"]
  }

  statement {
    effect = "Allow"

    actions = [
      "iam:GetInstanceProfile"
    ]

    resources = ["arn:aws:iam::*:instance-profile/*imagebuilder*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "iam:ListInstanceProfiles",
      "iam:ListRoles"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "iam:PassRole"
    ]

    resources = [
      "arn:aws:iam::*:instance-profile/*imagebuilder*",
      "arn:aws:iam::*:role/*imagebuilder*"
    ]

    condition {
      test = "StringEquals"
      variable = "iam:PassedToService"
      values = ["ec2.amazonaws.com"]
    }
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = ["arn:aws:s3::*:*imagebuilder*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "iam:CreateServiceLinkedRole"
    ]

    resources = ["arn:aws:iam::*:role/aws-service-role/imagebuilder.amazonaws.com/AWSServiceRoleForImageBuilder"]

    condition {
      test = "StringLike"
      variable = "iam:AWSServiceName"
      values = ["imagebuilder.amazonaws.com"]
    }
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeImages",
      "ec2:DescribeSnapshots",
      "ec2:DescribeVpcs",
      "ec2:DescribeRegions",
      "ec2:DescribeVolumes",
      "ec2:DescribeSubnets",
      "ec2:DescribeKeyPairs",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeInstanceTypeOfferings",
      "ec2:DescribeLaunchTemplates"
    ]

    resources = ["*"]
  }
}
