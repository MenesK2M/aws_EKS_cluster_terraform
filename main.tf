resource "aws_iam_role" "master-k8s" {
  name               = "masterEKSrole"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "eks.amazonaws.com"
                ]
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_policy_attachment" "masterEKS" {
  depends_on = [aws_iam_role.master-k8s]
  name       = "masterEks-role-policy"
  roles      = [aws_iam_role.master-k8s.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_eks_cluster" "control_plane" {
  name     = "mycluster"
  role_arn = aws_iam_role.master-k8s.arn

  vpc_config {
    subnet_ids = [data.aws_subnet.subnet_a.id, data.aws_subnet.subnet_b.id, data.aws_subnet.subnet_c.id, data.aws_subnet.subnet_d.id, data.aws_subnet.subnet_f.id]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_policy_attachment.masterEKS,
  ]
}

resource "aws_iam_role" "node-k8s" {
  name               = "nodeEKSrole"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Principal": {
                "Service": [
                    "ec2.amazonaws.com"
                ]
            }
        }
    ]
}
EOF
}

resource "aws_iam_policy_attachment" "nodek8s" {
  depends_on = [aws_iam_role.node-k8s]
  name       = "nodeEks-role-policy"
  roles      = [aws_iam_role.node-k8s.name]
  for_each   = toset(var.iam_role)
  policy_arn = "arn:aws:iam::aws:policy/${each.value}"
}

resource "aws_eks_node_group" "nodes" {
  cluster_name    = aws_eks_cluster.control_plane.name
  node_group_name = "nodegroup01"
  node_role_arn   = aws_iam_role.node-k8s.arn
  subnet_ids      = [data.aws_subnet.subnet_a.id, data.aws_subnet.subnet_b.id, data.aws_subnet.subnet_c.id, data.aws_subnet.subnet_d.id, data.aws_subnet.subnet_f.id]
  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }

  instance_types = [ "t2.micro" ]

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_policy_attachment.nodek8s,
    aws_eks_cluster.control_plane,
  ]
}

resource "null_resource" "local" {
  provisioner "local-exec" {
    command      = "aws eks --region us-east-1 update-kubeconfig --name ${aws_eks_cluster.control_plane.name}"
  }
  depends_on = [
    aws_eks_node_group.nodes,
  ]
}
