resource "aws_security_group" "vpce" {
  name        = "${var.project_name}-vpce"

  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTPS from private subnets"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"

    cidr_blocks = flatten([
      aws_subnet.private[*].cidr_block,
      aws_subnet.database[*].cidr_block
    ])
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  vpc_endpoint_type = "Gateway"
  service_name      = "com.amazonaws.us-east-1.s3"

  route_table_ids = aws_route_table.private[*].id
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = aws_vpc.main.id
  vpc_endpoint_type = "Gateway"
  service_name      = "com.amazonaws.us-east-1.dynamodb"

  route_table_ids = aws_route_table.private[*].id
}


resource "aws_vpc_endpoint" "sqs" {
  vpc_id            = aws_vpc.main.id
  vpc_endpoint_type = "Interface"
  service_name      = "com.amazonaws.us-east-1.sqs"

  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpce.id]

  subnet_ids = [
    aws_subnet.private[0].id,
    aws_subnet.private[1].id,
    aws_subnet.private[2].id
  ]

}


resource "aws_vpc_endpoint" "sns" {
  vpc_id            = aws_vpc.main.id
  vpc_endpoint_type = "Interface"
  service_name      = "com.amazonaws.us-east-1.sns"

  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpce.id]

  subnet_ids = [
    aws_subnet.private[0].id,
    aws_subnet.private[1].id,
    aws_subnet.private[2].id
  ]

}