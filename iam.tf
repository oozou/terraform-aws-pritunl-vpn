data "aws_iam_policy_document" "this" {
  statement {
    sid       = "IamPassRole"
    actions   = ["iam:PassRole"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ec2.amazonaws.com"]
    }
  }
  statement {
    sid = "ListEc2AndListInstanceProfiles"
    actions = [
      "iam:ListInstanceProfiles",
      "ec2:Describe*",
      "ec2:Search*",
      "ec2:Get*"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "this_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = format("%s-role", local.name)
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.this_assume_role.json
}

resource "aws_iam_role_policy" "this" {
  name = format("%s-policy", local.name)
  role = aws_iam_role.this.id

  policy = data.aws_iam_policy_document.this.json
}

resource "aws_iam_role_policy_attachment" "this" {
  count      = length(local.profile_policy_arns)
  role       = aws_iam_role.this.name
  policy_arn = local.profile_policy_arns[count.index]
}

resource "aws_iam_instance_profile" "this" {
  name = format("%s-profile", local.name)
  role = aws_iam_role.this.name
}
