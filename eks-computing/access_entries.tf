resource "aws_eks_access_entry" "nodes" {
  cluster_name  = aws_eks_cluster.main.id
  principal_arn = aws_iam_role.eks_nodes_role.arn
  type          = "EC2_LINUX"
}

resource "aws_eks_access_entry" "fargate" {
  cluster_name  = aws_eks_cluster.main.id
  principal_arn = aws_iam_role.fargate.arn
  type          = "FARGATE_LINUX"
}

resource "aws_eks_access_entry" "eks_developer" {
  cluster_name  = aws_eks_cluster.main.id
  principal_arn = aws_iam_role.eks_developer.arn
  type          = "STANDARD"

  tags = {
    Purpose = "Shared developer access"
  }
}

resource "aws_eks_access_policy_association" "eks_developer_edit" {
  cluster_name  = aws_eks_cluster.main.id
  principal_arn = aws_iam_role.eks_developer.arn

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [
    aws_eks_access_entry.eks_developer
  ]
}

resource "aws_eks_access_entry" "eks_admin" {
  cluster_name  = aws_eks_cluster.main.id
  principal_arn = aws_iam_role.eks_admin.arn
  type          = "STANDARD"

  tags = {
    Purpose = "Shared admin access"
  }
}


resource "aws_eks_access_policy_association" "eks_admin_edit" {
  cluster_name  = aws_eks_cluster.main.id
  principal_arn = aws_iam_role.eks_admin.arn

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [
    aws_eks_access_entry.eks_admin
  ]
}