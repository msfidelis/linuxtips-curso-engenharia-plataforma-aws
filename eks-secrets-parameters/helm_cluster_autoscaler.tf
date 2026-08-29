resource "helm_release" "cluster_autoscaler" {

  repository = "https://kubernetes.github.io/autoscaler"

  chart = "cluster-autoscaler"
  name  = "aws-cluster-autoscaler"

  namespace        = "kube-system"
  create_namespace = true

  set = [
    {
      name  = "replicaCount"
      value = 1
    },
    {
      name  = "awsRegion"
      value = var.region
    },
    {
      name  = "rbac.serviceAccount.create"
      value = true
    },
    {
      name  = "autoscalingGroups[0].name"
      value = aws_eks_node_group.main.resources[0].autoscaling_groups[0].name
    },
    {
      name  = "autoscalingGroups[0].maxSize"
      value = lookup(var.auto_scale_options, "max")
    },
    {
      name  = "autoscalingGroups[0].minSize"
      value = lookup(var.auto_scale_options, "min")
    },
    {
        name  = "extraArgs.scale-down-unneeded-time"
        value = "1m"
    }
  ]

  depends_on = [
    aws_eks_cluster.main,
    aws_eks_node_group.main,
  ]
}