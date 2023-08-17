variable "iam_role" {
  type    = list(string)
  default = ["AmazonEC2ContainerRegistryReadOnly", "AmazonEKS_CNI_Policy", "AmazonEKSWorkerNodePolicy"]
}

variable "exclude_availability_zone" {
  default = "us-east-1e"
}

variable "letter" {
  type    = list(string)
  default = ["a", "b", "c", "d", "f"]
}