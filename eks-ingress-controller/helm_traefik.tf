
resource "helm_release" "traefik" {
  name             = "traefik"
  repository       = "https://traefik.github.io/charts"
  chart            = "traefik"
  namespace        = "traefik"
  create_namespace = true

  set = [
    {
      name  = "service.spec.type"
      value = "ClusterIP"
    },
    {
      name  = "ports.web.port"
      value = 8000
    },
    {
      name  = "ports.traefik.port"
      value = 9000
    },
    {
      name  = "ingressClass.enabled"
      value = true
    },
    {
      name  = "ingressClass.name"
      value = "traefik"
    },
    {
      name  = "providers.kubernetesIngress.enabled"
      value = true
    },
    {
      name = "providers.kubernetesGateway.enabled"
      value = true
    },
    {
      name  = "gateway.enabled"
      value = false # não usamos o Gateway auto-provisionado pelo chart; declaramos o nosso em extras/traefik/gateway-api
    },
    {
      name  = "gatewayClass.enabled"
      value = false # idem para o GatewayClass
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

resource "kubectl_manifest" "traefik_tgb" {
  yaml_body = <<YAML
apiVersion: elbv2.k8s.aws/v1beta1
kind: TargetGroupBinding
metadata:
  name: traefik
  namespace: traefik
spec:
  serviceRef:
    name: traefik
    port: 80
  targetType: ip
  targetGroupARN: ${aws_lb_target_group.traefik_http.arn}
YAML

  depends_on = [
    helm_release.traefik,
  ]
}
