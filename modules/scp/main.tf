locals {
  policies = {
    deny_root_user = {
      name        = "DenyRootUser"
      description = "Prevent use of the root user in member accounts."
      document = {
        Version = "2012-10-17"
        Statement = [{
          Sid      = "DenyRootUser"
          Effect   = "Deny"
          Action   = "*"
          Resource = "*"
          Condition = {
            ArnLike = {
              "aws:PrincipalArn" = "arn:aws:iam::*:root"
            }
          }
        }]
      }
    }
    deny_leaving_organization = {
      name        = "DenyLeavingOrganization"
      description = "Prevent member accounts from leaving the organization."
      document = {
        Version = "2012-10-17"
        Statement = [{
          Sid      = "DenyLeavingOrganization"
          Effect   = "Deny"
          Action   = ["organizations:LeaveOrganization"]
          Resource = "*"
        }]
      }
    }
  }
}

resource "aws_organizations_policy" "this" {
  for_each = local.policies

  name        = each.value.name
  description = each.value.description
  type        = "SERVICE_CONTROL_POLICY"
  content     = jsonencode(each.value.document)
}

resource "aws_organizations_policy_attachment" "this" {
  for_each = aws_organizations_policy.this

  policy_id = each.value.id
  target_id = var.target_id
}
