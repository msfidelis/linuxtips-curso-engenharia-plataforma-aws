resource "aws_lb" "traefik" {
  name               = format("%s-traefik", var.project_name)
  internal           = false
  load_balancer_type = "network"

  subnets = data.aws_ssm_parameter.public_subnets[*].value

  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = true

  tags = {
    "kubernetes.io/cluster/${var.project_name}" = "shared"
  }
}


resource "aws_lb_target_group" "traefik_http" {
  name        = format("%s-traefik-http", var.project_name)
  port        = 80
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = data.aws_ssm_parameter.vpc.value

  health_check {
    protocol            = "HTTP"
    path                = "/ping"
    port                = "9000" # entrypoint "traefik" (ping/metrics), separado do proxy
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 10
    matcher             = "200"
  }
}

resource "aws_lb_listener" "traefik_80" {
  load_balancer_arn = aws_lb.traefik.arn
  port              = "80"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.traefik_http.arn
  }
}