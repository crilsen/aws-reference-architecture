# Session Handoff

## Resume block (read first)

- Repo state: branch `dev`, context checkpoint is committed; working tree remains dirty only with Terraform/module changes awaiting the root split.
- Source of truth: `AGENTS.md` → `.ai/`
- Budget / usage observed: unknown
- Checkpoint updated: 2026-09-14
- Last goal: Make the Lab deploy through a private self-hosted runner before creating EKS and ALB resources.
- Exact next action: Split `environments/lab` into bootstrap and Lab-platform Terraform roots; do not apply the monolithic root.
- Blocked by: None. AWS cleanup completed; local state is empty and `eks-lab` does not exist.
- Resume prompt: `Read AGENTS.md and .ai/HANDOFF.md. Continue from the Resume block. Do not rediscover context.`

## Operational facts

- The required NAT EIP is externally managed and must be preserved by Terraform destroy operations.
- The runner token is stored in SSM as a SecureString and expires; rotate it before creating/replacing the runner.
- The runner bootstrap must run the GitHub runner as the `actions` user. AL2023 has no `awscli2` package in the used repository; do not install it with dnf.
- Existing Jenkins paths are stale (`aws/...`) and should not be used for the new deployment path.
