resource "helm_release" "node_termination_handler" {
  name      = "aws-node-termination-handler"
  namespace = "kube-system"

  chart      = "aws-node-termination-handler"
  repository = "oci://public.ecr.aws/aws-ec2/helm"

  set = [
    {
      name  = "serviceAccount.create"
      value = true
    },
    {
      name  = "serviceAccount.name"
      value = "aws-node-termination-handler"
    },
    {
      name  = "awsRegion"
      value = var.region
    },
    {
      name  = "queueURL"
      value = aws_sqs_queue.node_termination.url
    },
    {
      name  = "enableSqsTerminationDraining"
      value = true
    },
    {
      name  = "deleteSqsMsgIfNodeNotFound"
      value = true
    },
    {
      name  = "checkTagBeforeDraining"
      value = false
    },
  ]

  depends_on = [
    aws_eks_addon.pod_identity,
    aws_eks_pod_identity_association.node_termination_handler,
  ]

}