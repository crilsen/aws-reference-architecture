# Current Work

## Active

- Refactor the Lab from a monolithic Terraform root into bootstrap and Lab-platform states.

## Next

1. Create bootstrap for network, supplied NAT EIP, endpoints, and private GitHub runner.
2. Move EKS/IAM/add-ons/registry/observability to Lab-platform state with a separate backend key.
3. Add Terraform-managed AWS Load Balancer Controller, IAM, Helm deployment, and public Ingress.
4. Update the runner workflow to apply Lab-platform state and run smoke tests.
5. Migrate both states to `cn-terraform-state-us-east-1` using separate keys and S3 lockfiles.

## Completed

- Destroyed the failed monolithic Lab; Terraform state is empty and `eks-lab` no longer exists.
- Removed generated Lab plans and added an ignore rule.
- Added and pushed the private-runner smoke workflow on `dev`.
- Corrected runner bootstrap execution and tooling; removed the invalid AL2023 `awscli2` install.
- Committed and pushed the network tiers, EKS hardening, VPC endpoint/security-group, and `github-runner` module changes (`851d262`) with account id and NAT EIP as versioned placeholders.
