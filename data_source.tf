data "aws_vpc" "my_vpc" {
  default = true
}

data "aws_subnet" "subnet_a" {
  vpc_id                  = data.aws_vpc.my_vpc.id
  cidr_block              = "172.31.0.0/20"
  availability_zone       = "us-east-1a"
}

data "aws_subnet" "subnet_b" {
  vpc_id                  = data.aws_vpc.my_vpc.id
  cidr_block              = "172.31.80.0/20"
  availability_zone       = "us-east-1b"
}

data "aws_subnet" "subnet_c" {
  vpc_id                  = data.aws_vpc.my_vpc.id
  cidr_block              = "172.31.16.0/20"
  availability_zone       = "us-east-1c"
}

data "aws_subnet" "subnet_d" {
  vpc_id                  = data.aws_vpc.my_vpc.id
  cidr_block              = "172.31.32.0/20"
  availability_zone       = "us-east-1d"
}

data "aws_subnet" "subnet_f" {
  vpc_id                  = data.aws_vpc.my_vpc.id
  cidr_block              = "172.31.64.0/20"
  availability_zone       = "us-east-1f"
}