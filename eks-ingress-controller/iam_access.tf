resource "aws_iam_group" "eks_developers" {
  name = "eks-developers"
  path = "/groups/"
}

resource "aws_iam_role" "eks_developer" {
  name                 = "${var.project_name}-developer-role"
  path                 = "/eks/"
  max_session_duration = 14400

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowPrincipalsFromCurrentAccount"
        Effect = "Allow"

        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Purpose = "Shared EKS developer access"
  }
}

resource "aws_iam_group_policy" "assume_eks_developer_role" {
  name  = "${var.project_name}-assume-eks-developer"
  group = aws_iam_group.eks_developers.name

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid      = "AssumeEksDeveloperRole"
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = aws_iam_role.eks_developer.arn
      },
     {
        Sid      = "DescribeEksCluster"
        Effect   = "Allow"
        Action   = "eks:DescribeCluster"
        Resource = "arn:aws:eks:${var.region}:${data.aws_caller_identity.current.account_id}:cluster/${var.project_name}"
      }      
    ]
    
  })
}