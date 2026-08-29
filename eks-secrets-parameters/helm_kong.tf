resource "helm_release" "kong" {
  name             = "kong"
  repository       = "https://charts.konghq.com"
  chart            = "kong"
  namespace        = "kong"
  create_namespace = true

  set = [
    {
      name  = "ingressController.enabled"
      value = true
    },
    {
      name  = "ingressController.ingressClass"
      value = "kong"
    },
    {
      name  = "proxy.enabled"
      value = true
    },
    {
      name  = "proxy.type"
      value = "ClusterIP"
    },
    {
      name  = "status.enabled"
      value = true
    },
    {
      name  = "admin.enabled"
      value = false
    },
    {
      name  = "manager.enabled"
      value = false
    },
    {
      name  = "portal.enabled"
      value = false
    },
    // Resources
    {
      name  = "resources.requests.cpu"
      value = "100m"
    },
    {
      name  = "resources.requests.memory"
      value = "128Mi"
    },
    {
      name  = "resources.limits.cpu"
      value = "200m"
    },
    {
      name  = "resources.limits.memory"
      value = "256Mi"
    },

    // Resources - Ingress Controller
    {
      name  = "ingressController.resources.requests.cpu"
      value = "100m"
    },
    {
      name  = "ingressController.resources.requests.memory"
      value = "128Mi"
    },
    {
      name  = "ingressController.resources.limits.cpu"
      value = "200m"
    },
    {
      name  = "ingressController.resources.limits.memory"
      value = "256Mi"
    },

    // Autoscaling
    {
      name  = "autoscaling.enabled"
      value = true
    },
    {
      name  = "autoscaling.minReplicas"
      value = 2
    },
    {
      name  = "autoscaling.maxReplicas"
      value = 10
    },
    {
      name  = "autoscaling.metrics[0].type"
      value = "Resource"
    },
    {
      name  = "autoscaling.metrics[0].resource.name"
      value = "cpu"
    },
    {
      name  = "autoscaling.metrics[0].resource.target.type"
      value = "Utilization"
    },
    {
      name  = "autoscaling.metrics[0].resource.target.averageUtilization"
      value = 50
    }    
  ]

  depends_on = [
    aws_eks_cluster.main,
  ]
}


resource "kubectl_manifest" "kong_tgb" {
  yaml_body = <<YAML
apiVersion: elbv2.k8s.aws/v1beta1
kind: TargetGroupBinding
metadata:
  name: kong
  namespace: kong
spec:
  serviceRef:
    name: kong-kong-proxy
    port: 80
  targetGroupARN: ${aws_lb_target_group.kong_http.arn}
YAML


  depends_on = [
    helm_release.kong,
  ]

}