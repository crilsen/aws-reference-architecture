data "aws_ssm_parameter" "amazon_linux" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

data "aws_caller_identity" "current" {}

locals {
  common_tags = merge(var.tags, { Project = var.project_name, ManagedBy = "Terraform" })
}

data "aws_iam_policy_document" "runner_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "registration_token" {
  statement {
    actions   = ["ssm:GetParameter"]
    resources = ["arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter${var.registration_token_parameter_name}"]
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.project_name}-github-runner"
  assume_role_policy = data.aws_iam_policy_document.runner_assume_role.json
  tags               = merge(local.common_tags, { Name = "${var.project_name}-github-runner" })
}

resource "aws_iam_role_policy" "registration_token" {
  name   = "${var.project_name}-github-runner-registration-token"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.registration_token.json
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "deployment" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.project_name}-github-runner"
  role = aws_iam_role.this.name
}

resource "aws_security_group" "this" {
  name        = "${var.project_name}-github-runner-sg"
  description = "Egress-only security group for the private GitHub Actions runner."
  vpc_id      = data.aws_subnet.selected.vpc_id
  tags        = merge(local.common_tags, { Name = "${var.project_name}-github-runner-sg" })
}

data "aws_subnet" "selected" { id = var.subnet_id }

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.this.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "cluster_api" {
  security_group_id            = var.cluster_security_group_id
  referenced_security_group_id = aws_security_group.this.id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
  description                  = "Private Kubernetes API access from the GitHub Actions runner."
}

resource "aws_instance" "this" {
  ami                         = data.aws_ssm_parameter.amazon_linux.value
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  iam_instance_profile        = aws_iam_instance_profile.this.name
  vpc_security_group_ids      = [aws_security_group.this.id]
  user_data_replace_on_change = true
  user_data = templatefile("${path.module}/user-data.sh.tftpl", {
    aws_region     = var.aws_region
    repository_url = var.github_repository_url
    parameter_name = var.registration_token_parameter_name
    runner_name    = "${var.project_name}-github-runner"
    runner_version = var.runner_version
  })

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = 30
  }

  tags = merge(local.common_tags, { Name = "${var.project_name}-github-runner" })
}
