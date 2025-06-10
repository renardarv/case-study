data "aws_iam_policy" "ec2_readonly" {
  name = "AmazonEC2ReadOnlyAccess"
}

data "aws_iam_policy" "admin" {
  name = "AdministratorAccess"
}

module "iam_user_admin {
  source = "../../../../00-modules/users/v0.2.0/modules/iam-user"

  name = "readonly"

  create_iam_user_login_profile = true
  create_iam_access_key         = true
  policy_arns                   = [data.aws_iam_policy.example.arn]
}


module "iam_user_readonly" {
  source = "../../../../00-modules/users/v0.2.0/modules/iam-user"

  name = "readonly"

  create_iam_user_login_profile = true
  create_iam_access_key         = true
  policy_arns                   = [data.aws_iam_policy.example.arn]
}
