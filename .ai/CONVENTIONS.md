# Conventions

- AWS resource names use the lowercase `eks-lab` prefix.
- Terraform uses environment roots and reusable `modules/`.
- Lab tags include `Project`, `Environment`, `ManagedBy`, and `Purpose`.
- Keep account identity and EIP allocation IDs in private tfvars, not docs, context, or workflows.
- Generated plans are local artifacts; `.gitignore` excludes `environments/*/tfplan*`, state, provider directories, and credentials.
- Keep the EKS API private and apply platform resources from the private runner.
- Use Terraform for AWS infrastructure, Load Balancer Controller IAM, and Helm deployment.
- Preserve explicit ordering: EBS CSI Pod Identity precedes the EBS CSI add-on.
