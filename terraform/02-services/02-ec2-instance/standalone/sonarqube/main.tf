module "bastion" {
  source = "../../"

  name = "sonarqube"

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t4g.large" # used to set core count below
  availability_zone      = element(module.vpc.azs, 0)
  subnet_id              = "subnet-global111"
  vpc_security_group_ids = ["sg-xxxx"]
  create_eip             = true
  disable_api_stop       = false

  create_iam_instance_profile = true
  iam_role_description        = "IAM role for EC2 instance"
  iam_role_policies = {
    AdministratorAccess = "arn:aws:iam::aws:policy/AdministratorAccess"
  }

  # only one of these can be enabled at a time
  hibernation = true
  # enclave_options_enabled = true

  user_data_base64            = base64encode(local.user_data)
  user_data_replace_on_change = true

  enable_volume_tags = true
  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      throughput  = 200
      volume_size = 50
      tags = {
        Name = "my-root-block"
      }
    },
  ]

  ebs_block_device = [
    {
      device_name = "/dev/sdf"
      volume_type = "gp3"
      volume_size = 5
      throughput  = 200
      encrypted   = true
      kms_key_id  = aws_kms_key.this.arn
      tags = {
        MountPoint = "/mnt/data"
      }
    }
  ]

  tags = local.tags
}