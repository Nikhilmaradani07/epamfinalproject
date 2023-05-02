provider "aws" {
  region = "us-east-1"
}

resource "aws_ecs_task_definition" "epam_ecs" {
  family                   = "example-task"
  container_definitions    = jsonencode([
    {
      name      = "epam_ecs"
      image     = "nginx:latest"
      cpu       = 256
      memory    = 512
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}

resource "aws_ecr_repository" "epam1-repository" {
  name                 = "epam1-repository"
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

# Create a new VPC
resource "aws_vpc" "epam-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "epam-vpc"
  }
}

# Create a new subnet in the VPC
resource "aws_subnet" "epam-subnet" {
  vpc_id = aws_vpc.epam-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1c"

  tags = {
    Name = "epam-subnet"
  }
}

# Create a new security group for the ECS cluster
resource "aws_security_group" "epam-security-group" {
  name_prefix = "epam-security-group"
  vpc_id = aws_vpc.epam-vpc.id

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an ECS cluster
resource "aws_ecs_cluster" "epam-cluster" {
  name = "epam-cluster"
}

