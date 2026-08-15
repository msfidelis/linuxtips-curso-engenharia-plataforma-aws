resource "aws_security_group_rule" "port_8000" {
  cidr_blocks = ["0.0.0.0/0"]
  
  from_port   = 8000
  to_port     = 8000
  description = "kong"
  protocol    = "tcp"

  security_group_id = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
  type              = "ingress"
}