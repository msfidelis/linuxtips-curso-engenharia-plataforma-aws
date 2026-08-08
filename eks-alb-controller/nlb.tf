resource "aws_lb" "ingress" {
  name               = var.project_name
  internal           = false
  load_balancer_type = "network"

  subnets = data.aws_ssm_parameter.public_subnets[*].value

  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = true

  tags = {
    "kubernetes.io/cluster/${var.project_name}" = "shared"
  }
}


resource "aws_lb_target_group" "http" {
  name              = format("%s-http", var.project_name)
  port              = 8080
  protocol          = "TCP"
  target_type       = "ip"
  vpc_id            = data.aws_ssm_parameter.vpc.value
}


resource "aws_lb_listener" "ingress_80" {
  load_balancer_arn = aws_lb.ingress.arn
  port              = "80"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http.arn
  }
}