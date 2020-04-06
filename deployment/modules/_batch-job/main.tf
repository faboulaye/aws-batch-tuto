resource "aws_iam_role" "ecs_instance_role" {
  name               = "ecs_instance_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance_role" {
  name = "ecs_instance_role"
  role = aws_iam_role.ecs_instance_role.name
}

resource "aws_iam_role" "aws_batch_service_role" {
  name               = "aws_batch_service_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "batch.amazonaws.com"
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "aws_batch_service_role" {
  role       = aws_iam_role.aws_batch_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}

data "aws_cloudformation_export" "batch-vpc" {
  name = var.batch-vpc-id
}

resource "aws_security_group" "batch-sg" {
  name = var.batch-sg
  vpc_id = data.aws_cloudformation_export.batch-vpc.value
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_cloudformation_export" "batch-subnet" {
  name = var.batch-cpt-subnet
}

resource "aws_batch_compute_environment" "batch-cpt-env" {
  compute_environment_name = var.batch-cpt-env
  service_role             = aws_iam_role.aws_batch_service_role.arn
  type                     = "MANAGED"
  depends_on               = [aws_iam_role_policy_attachment.aws_batch_service_role]

  compute_resources {
    instance_role      = aws_iam_instance_profile.ecs_instance_role.arn
    instance_type      = ["c4.large"]
    max_vcpus          = 2
    min_vcpus          = 0
    desired_vcpus      = 1
    security_group_ids = [aws_security_group.batch-sg.id]
    subnets            = [data.aws_cloudformation_export.batch-subnet.value]
    type               = "EC2"
  }
}

resource "aws_batch_job_definition" "batch-job-def" {
  name                 = var.batch-job-def
  type                 = "container"
  container_properties = <<CONTAINER_PROPERTIES
{
    "image": "faboulaye/aws-batch-tuto:1.0.0",
    "memory": 120,
    "vcpus": 1
}
CONTAINER_PROPERTIES
}

resource "aws_batch_job_queue" "batch-job-queue" {
  name                 = var.batch-job-queue
  state                = "ENABLED"
  priority             = "1"
  compute_environments = [aws_batch_compute_environment.batch-cpt-env.arn]
}
