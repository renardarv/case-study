module "developer-group" {
  source = "../../../../00-modules/users/v0.2.0/modules/iam-group-with-assumable-roles-policy"

  name = "production-dev"

  assumable_roles = ["arn:aws:iam::111111111111:role/admin"]

  group_users = [
    "dev1",
    "dev2",
  ]
}

module "devops-group" {
  source = "../../../../00-modules/users/v0.2.0/modules/iam-group-with-assumable-roles-policy"

  name = "production-dev"

  assumable_roles = ["arn:aws:iam::111111111111:role/admin"]

  group_users = [
    "devops1",
    "devops2",
  ]
}
