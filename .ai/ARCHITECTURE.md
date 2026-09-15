# Architecture

## Observed architecture

```text
Lab AWS account
└── eks-lab prefix
    ├── VPC: two AZs, public/private/endpoints tiers, NAT and supplied EIP
    ├── VPC endpoints: S3, ECR, EC2, EKS, EKS Auth, ELB, Logs, STS
    ├── IAM: EKS cluster, node, and EBS CSI Pod Identity roles
    ├── EKS 1.36: private API, managed nodes, core add-ons, EBS CSI
    ├── ECR and CloudWatch logs
    └── private EC2 GitHub Actions runner
```

## Required deployment boundary

`bootstrap` owns VPC/NAT/EIP/endpoints and the runner only. `lab` owns EKS, nodes, add-ons, EBS CSI identity, registry/observability, AWS Load Balancer Controller, and Kubernetes Ingress resources. No workstation applies the Lab platform state.

## In progress

The failed monolithic Lab was destroyed cleanly. EBS CSI Pod Identity was reordered before the EBS CSI add-on, but the Terraform roots still need splitting.
