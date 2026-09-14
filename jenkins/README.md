# Jenkins jobs for AWS Terraform

The repository provides independent Pipeline jobs for each AWS infrastructure boundary. Configure each Jenkins job with **Pipeline script from SCM** and the corresponding script path:

| Job | Script path | Purpose |
| --- | --- | --- |
| EKS | `aws/jenkins/eks/Jenkinsfile` | Validate, plan, and optionally apply the complete EKS lab environment. |
| EKS Production | `aws/jenkins/eks-production/Jenkinsfile` | Validate, plan, and optionally apply the Production EKS environment with a dedicated approval gate. |
| Organizations | `aws/jenkins/organization/Jenkinsfile` | Validate, plan, and optionally apply the organization, member accounts, OU, and SCPs. |
| IAM | `aws/jenkins/iam/Jenkinsfile` | Validate the EKS root and produce an IAM-only review plan. |
| VPC | `aws/jenkins/vpc/Jenkinsfile` | Validate the EKS root and produce a network-only review plan. |
| Registry | `aws/jenkins/registry/Jenkinsfile` | Validate the EKS root and produce an ECR-only review plan. |
| Observability | `aws/jenkins/observability/Jenkinsfile` | Validate the EKS root and produce a CloudWatch-only review plan. |
| SCP | `aws/jenkins/scp/Jenkinsfile` | Validate the Organizations root and produce an SCP-only review plan. |

## Agent requirements

The Jenkins agent must provide Terraform, Git, and AWS authentication. Prefer an IAM role attached to an ephemeral agent or an external workload-identity mechanism. Do not store access keys in a Jenkinsfile, repository variable file, console command, or build artifact.

The organization job must start with credentials from the intended AWS Organizations management account. Workload jobs use the explicit `assume_role` configuration in their Terraform root. Account-ID checks stop plans when the resulting identity does not match the expected Lab or Production account.

## Actions

- `validate` runs formatting, initialization, and validation without creating a plan.
- `plan` creates a binary Terraform plan in the build workspace.
- `apply` is available only for EKS and Organizations and requires interactive approval after the plan stage.

The IAM, VPC, Registry, Observability, and SCP jobs deliberately exclude `apply`. Applying a targeted Terraform plan can leave dependencies only partially converged. Use these outputs for focused review, then run the complete EKS or Organizations job for deployment.

## State and concurrency

Each Terraform root requires its own remote backend before shared CI use. Local state in an ephemeral Jenkins workspace is not suitable for collaborative deployment. Concurrent builds are disabled per job, but backend locking remains required across jobs and other automation.

Plan files can contain sensitive values. The pipelines do not archive them. Configure ephemeral workspaces or secure cleanup according to the Jenkins agent lifecycle.
