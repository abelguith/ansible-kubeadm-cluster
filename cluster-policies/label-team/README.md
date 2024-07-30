# Require Labels Policy

## Overview
- **Policy Name**: require-labels
- **Category**: Best Practices
- **Severity**: Medium
- **Subject**: Pod, Label

## Description
This policy enforces the use of labels that identify semantic attributes of your application or Deployment. A common set of labels allows tools to work collaboratively, describing objects in a common manner that all tools can understand. The recommended labels describe applications in a way that can be queried. This policy validates that the label `team` is specified with some value for all Pods.

## Rule: Check for Labels

### Match Criteria
- **Resource Kinds**: Pod

### Validation
- **Message**: "The label `Team` is required."
- **Required Label**: 
  - `team`: Must be present with any non-empty value

## Policy Details
- **Validation Failure Action**: audit
- **Background**: true

## How to Use
1. Apply this policy to your Kubernetes cluster using : `kubectl apply -f label-team.yml`x
