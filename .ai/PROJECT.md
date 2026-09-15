# Project

## Identity

- **Name:** aws-reference-architecture
- **Objective:** Terraform reference architecture for AWS Organizations and a Lab EKS platform.
- **Primary technologies:** Terraform `>= 1.6`, AWS provider `~> 6.0`, Amazon EKS, GitHub Actions, Jenkins, Kubernetes manifests.
- **Environment:** `us-east-1` Lab; the expected account is supplied privately through `environments/lab/terraform.tfvars`.

## Observed

- Terraform roots exist for `organization`, `lab`, and `production`.
- Reusable modules provide networking, IAM, EKS, ECR, observability, Organizations/SCPs, and a private GitHub Actions runner.
- The Lab VPC uses two AZs, public/private/endpoints subnet tiers, one NAT Gateway, an externally supplied EIP, and VPC endpoints.
- The intended Lab EKS version is 1.36 with a private API endpoint and a single `t3.small` managed node.
- GitHub Actions has a public-safety scanner and a self-hosted-runner smoke workflow. Jenkins jobs exist but reference an `aws/` path not present in this checkout.

## Current delivery model

The approved target is two-stage deployment: **bootstrap** creates networking and the private runner; the runner then applies the **Lab platform** (EKS, add-ons, ALB Controller, and Ingress). The monolithic Lab root does not yet implement this split.
