# AWS: Organizations and EKS

AWS is the comparison baseline. Governance and workloads are independent Terraform roots with separate state.

## Hierarchy

```text
Management account (existing caller)
└── Workloads OU
    ├── Lab member account
    └── Production member account
```

Terraform does not create or rename the management account. The Organizations root verifies `management_account_id` against the active caller before managing the organization. It enables Organizations features and SCPs, creates the OU and member accounts, and protects account resources from destroy. `close_on_deletion` is disabled.

The SCP catalog denies root-user API activity and prevents members from leaving the organization. SCPs cap permissions; they do not grant IAM access and do not constrain the management account.

```bash
cd environments/organization
terraform init
terraform validate
terraform plan -var-file=terraform.tfvars
```

Use unique account e-mails privately. Import existing organizations or accounts instead of duplicating them.

## Lab deployment flow

The Lab is intentionally deployed in two stages. The workstation only creates
the minimum private foundation and the self-hosted GitHub Actions runner. All
Kubernetes-facing infrastructure is then applied from that runner, inside the
VPC. This keeps the EKS API private and makes CI the single execution path for
the application platform.

```text
Operator workstation
  └── bootstrap state: VPC, NAT with supplied EIP, endpoints, runner VM
        └── GitHub Actions self-hosted runner (private subnet)
              └── lab state: EKS, nodes, add-ons, ALB controller, ingress
```

### Stage 1 — bootstrap

Run this stage from an authenticated operator workstation. It creates no EKS
cluster and never enables a public EKS endpoint. The runner registration token
is stored as a SecureString in SSM Parameter Store and must be refreshed before
creating or replacing the runner.

```bash
cd environments/bootstrap
terraform init
terraform validate
terraform plan -var-file=terraform.tfvars -out=tfplan-bootstrap
terraform apply tfplan-bootstrap
```

Confirm the runner is `online` in GitHub Actions before proceeding.

### Stage 2 — Lab platform

Trigger the Lab workflow from GitHub Actions. It runs on labels
`self-hosted`, `eks-lab`, and `private-vpc`; it is the only supported path for
applying EKS, add-ons, AWS Load Balancer Controller, and public Ingress.

```text
Actions → Private runner → Terraform lab state → EKS → ALB Controller → ALB
```

The AWS Load Balancer Controller is managed by Terraform/Helm. A Kubernetes
`Ingress` with class `alb` creates the public ALB; no ALB is provisioned until
an Ingress exists.

## EKS architecture

The `us-east-1` workload root composes:

- `network`: VPC, two public and two private subnets, Internet Gateway, NAT Gateway, routes, endpoint security group, S3 gateway endpoint, and ECR/Logs/STS interface endpoints.
- `iam`: separate EKS control-plane and managed-node roles.
- `eks`: KMS secret encryption, control-plane logging, managed nodes, CoreDNS, kube-proxy, VPC CNI, and Pod Identity agent.
- `registry`: encrypted ECR, immutable tags, push scanning, and retention.
- `observability`: CloudWatch log retention.

```bash
cd environments/lab
terraform init
terraform validate
terraform plan -var-file=terraform.tfvars
```

The EKS API endpoint is private. One NAT Gateway reduces lab cost but is not
zonally resilient. Terraform state belongs in the designated S3 backend
`cn-terraform-state-us-east-1`; do not commit state or plan artifacts.

## Terraform hygiene

Never keep or commit generated plan files. Use a short-lived plan file only
when applying it immediately, then remove it. The repository ignores all
`environments/*/tfplan*` files, Terraform state, provider directories, and
credentials.

## Enforced account boundaries

The Lab and Production roots are separate configurations with separate `terraform.tfvars` and state. Each provider constructs an explicit cross-account role ARN, assumes that role, reads the resulting caller identity, and compares it with the expected account ID. A mismatch stops the plan.

| Terraform root | Required account | Environment tag |
| --- | --- | --- |
| `environments/organization` | Management | Governance context |
| `environments/lab` | Lab | `Lab` |
| `environments/production` | Production | `Production` |

The member-account IDs are obtained from the Organizations outputs and inserted privately into the appropriate workload `terraform.tfvars`. Never reuse one account ID across Lab and Production.

## Jenkins automation

Pipeline jobs are available for EKS, Organizations, IAM, VPC, ECR, CloudWatch observability, and SCPs. EKS and Organizations support validate, plan, and manually approved apply operations. Component jobs support validation and focused review plans only. See [`jenkins/README.md`](jenkins/README.md) for job paths, credentials, state, and safety requirements.
