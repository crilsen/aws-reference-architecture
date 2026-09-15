# Tools

## Current availability

Terraform `>= 1.6` with AWS provider `~> 6.0` is configured. AWS credentials and GitHub CLI authentication are required for live operations. Never store their values or runner registration tokens here.

## Allowed without additional authorization

- Read and search repository files.
- Make scoped task-related edits.
- Run project formatters, linters, tests, syntax checks, and validation commands when they exist.
- Run read-only commands and safe dry runs.
- Update this portable context.
- `terraform fmt`, `terraform validate`, and read-only AWS/GitHub status commands.

## Requires explicit authorization

- Deployment or production changes.
- `terraform apply`, `terraform destroy`, state migration, runner-token rotation, GitHub workflow dispatch, or any paid AWS resource creation.
- `terraform apply`, `terraform destroy`, `tofu apply`, or `tofu destroy`.
- `kubectl apply` against a real cluster, `kubectl delete`, or equivalent cluster mutation.
- Secret changes, destructive state operations, irreversible changes, paid-resource creation, or any external operation with material impact.

## Technology-specific guidance when adopted

| Technology | Usually safe | Restricted |
| --- | --- | --- |
| Terraform/OpenTofu | `fmt`, `validate`, `plan` | `apply`, `destroy` |
| Kubernetes | `get`, `describe`, `diff`, client dry-run | real-cluster apply/delete |
| Helm | `lint`, `template` | install/upgrade against real environments |
| Static analysis | `tflint`, `checkov`, `trivy`, `shellcheck` | Follow tool/project-specific impact rules |

Before running a command, confirm it is appropriate for the repository and does not require unavailable credentials or mutate external systems.
