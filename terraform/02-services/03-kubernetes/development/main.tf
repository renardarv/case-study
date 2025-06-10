#---------------------------------------------------------------
# EKS Blueprints
#---------------------------------------------------------------

module "eks-example" {
  source = "../../../../00-modules/vpc/v0.2.0"

  cluster_name                    = "example"
  cluster_version                 = "1.31"
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  cluster_enabled_log_types       = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  enable_irsa = true

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  iam_role_name            = "example-cluster-role"
  iam_role_use_name_prefix = false

  kms_key_aliases = [local.name]

  enable_cluster_creator_admin_permissions = true
  authentication_mode                      = "API_AND_CONFIG_MAP"
  access_entries = {
    readonly = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::910325995766:user/readonly"

      policy_associations = {
        production-view = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
          access_scope = {
            namespaces = ["production"]
            type       = "namespace"
          }
        }
      }
    }
    admin = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::910325995766:user/admin"

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
    gitlab = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::910325995766:user/gitlab-runner"

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  cluster_security_group_additional_rules = {
    ingress_nodes_ephemeral_ports_tcp = {
      description                = "Nodes on ephemeral ports"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "ingress"
      source_node_security_group = true
    }
  }

  # Extend node-to-node security group rules
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
  }

  eks_managed_node_groups = {
    k8s-prod-initial = {
      instance_types          = ["m6a.large"]
      capacity_type           = "ON_DEMAND"
      min_size                = 3
      max_size                = 5
      desired_size            = 3
      subnet_ids              = module.vpc.private_subnets
      pre_bootstrap_user_data = <<-EOT
        #!/bin/bash
        set -ex
        cat <<-EOF > /etc/profile.d/bootstrap.sh
        export USE_MAX_PODS=false
        export KUBELET_EXTRA_ARGS="--max-pods=58"
        EOF
        # Source extra environment variables in bootstrap script
        sed -i '/^set -o errexit/a\\nsource /etc/profile.d/bootstrap.sh' /etc/eks/bootstrap.sh
        EOT

      labels = {
        infraNode = "general"
      }
      taints = [
        {
          key    = "node.cilium.io/agent-not-ready"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      ]
    }
  }

  tags = local.tags
  node_security_group_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = null
  }
}

module "eks_blueprints_kubernetes_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "1.15.1"

  cluster_name      = module.eks_blueprints.cluster_name
  cluster_endpoint  = module.eks_blueprints.cluster_endpoint
  cluster_version   = module.eks_blueprints.cluster_version
  oidc_provider_arn = module.eks_blueprints.oidc_provider_arn

  # EKS Managed Add-ons
  eks_addons = {
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
    }
    coredns = {
      most_recent = true
    }
  }

  # Add-ons
  enable_metrics_server = true

  depends_on = [module.eks_blueprints]
}

module "ebs_csi_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.35.0"

  role_name = "${module.eks_blueprints.cluster_name}-ebs-csi-driver-role"

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks_blueprints.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = local.tags
}
