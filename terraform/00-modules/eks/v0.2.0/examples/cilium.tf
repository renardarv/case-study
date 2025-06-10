#---------------------------------------------------------------
# cilium
#---------------------------------------------------------------

data "aws_eks_cluster_auth" "cluster" {
  name = local.name
}

resource "null_resource" "delete_aws_cni" {
  provisioner "local-exec" {
    command = "curl -s -k -XDELETE -H 'Authorization: Bearer ${data.aws_eks_cluster_auth.cluster.token}' -H 'Accept: application/json' -H 'Content-Type: application/json' '${module.eks_blueprints.cluster_endpoint}/apis/apps/v1/namespaces/kube-system/daemonsets/aws-node'"
  }
}

resource "null_resource" "delete_kube_proxy" {
  provisioner "local-exec" {
    command = "curl -s -k -XDELETE -H 'Authorization: Bearer ${data.aws_eks_cluster_auth.cluster.token}' -H 'Accept: application/json' -H 'Content-Type: application/json' '${module.eks_blueprints.cluster_endpoint}/apis/apps/v1/namespaces/kube-system/daemonsets/kube-proxy'"
  }
}

resource "kubernetes_config_map" "cni_config" {
  metadata {
    name      = "cni-configuration"
    namespace = "kube-system"
  }
  data = {
    "cni-config" = <<EOF
{
  "cniVersion":"0.3.1",
  "name":"cilium",
  "plugins": [
    {
      "cniVersion":"0.3.1",
      "type":"cilium-cni",
      "eni": {
        "subnet-tags":{
          "Usage":"${local.name}-pods"
        }
      }
    }
  ]
}
EOF
  }

  depends_on = [module.eks_blueprints]
}

data "aws_iam_policy_document" "cilium" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcs",
      "ec2:DescribeSecurityGroups",
      "ec2:CreateNetworkInterface",
      "ec2:AttachNetworkInterface",
      "ec2:ModifyNetworkInterfaceAttribute",
      "ec2:AssignPrivateIpAddresses",
      "ec2:CreateTags",
      "ec2:UnassignPrivateIpAddresses",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeInstanceTypes"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "cilium" {
  name   = "${local.name}-cilium_operator_eks_policy"
  policy = data.aws_iam_policy_document.cilium.json

  tags = local.tags
}

module "cilium_operator_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.35.0"

  role_name = "${local.name}-cilium-operator-role"

  role_policy_arns = {
    policy = aws_iam_policy.cilium.arn
  }

  oidc_providers = {
    main = {
      provider_arn               = module.eks_blueprints.oidc_provider_arn
      namespace_service_accounts = ["kube-system:cilium-operator"]
    }
  }

  tags = local.tags
}

data "http" "service_monitor_crd" {
  url = "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml"

  request_headers = {
    Accept = "text/yaml"
  }
}

resource "kubectl_manifest" "service_monitor_crd" {
  yaml_body = data.http.service_monitor_crd.response_body

  depends_on = [module.eks_blueprints]
}

resource "helm_release" "cilium" {
  namespace        = "kube-system"
  create_namespace = false
  name             = "cilium"
  repository       = "https://helm.cilium.io/"
  chart            = "cilium"
  version          = "v1.16.4"

  values = [
    <<EOF
upgradeCompatibility: "1.15"
cni:
  configMap: cni-configuration
  customConf: true
eni:
  enabled: true
  iamRole: "${module.cilium_operator_irsa_role.iam_role_arn}"
  updateEC2AdapterLimitViaAPI: true
  awsEnablePrefixDelegation: true
  awsReleaseExcessIPs: true
egressMasqueradeInterfaces: eth0
loadBalancer:
  algorithm: maglev
kubeProxyReplacement: true
k8sServiceHost: ${replace(module.eks_blueprints.cluster_endpoint, "/(^\\w+:|^)\\/\\//", "")}
k8sServicePort: 443
bandwidthManager:
  enabled: true
  bbr: false
localRedirectPolicy: true
ipam:
  mode: eni
prometheus:
  enabled: true
  serviceMonitor:
    enabled: true
    interval: "15s"
dashboards:
  enabled: true
operator:
  prometheus:
    enabled: true
    serviceMonitor:
      enabled: true
      interval: "15s"
  dashboards:
    enabled: true
hubble:
  relay:
    enabled: true
  ui:
    enabled: true
  metrics:
    enabled: [dns:query;ignoreAAAA,drop,tcp,flow,icmp,http,port-distribution]
    serviceMonitor:
      enabled: true
      interval: "15s"
    dashboards:
      enabled: true
nodeinit:
  enabled: false
routingMode: native
envoy:
  enabled: false
EOF
  ]

  depends_on = [
    null_resource.delete_aws_cni,
    null_resource.delete_kube_proxy,
    kubectl_manifest.service_monitor_crd,
    module.eks_blueprints
  ]
}
