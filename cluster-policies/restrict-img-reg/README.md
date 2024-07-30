# Restrict Image Registries Policy

## Overview
- **Policy Name**: restrict-image-registries
- **Category**: Best Practices
- **Severity**: Medium
- **Subject**: Pod
- **Minimum Kyverno Version**: 1.6.0

## Description
Images from unknown, public registries can be of dubious quality and may not be scanned and secured, representing a high degree of risk. Requiring use of known, approved registries helps reduce threat exposure by ensuring image pulls only come from them. This policy validates that container images only originate from the registry `starkregistry.azurecr.io` or `docker.io`. Use of this policy requires customization to define your allowable registries.

## Rules

### 1. Validate Registries
- **Name**: validate-registries
- **Description**: Ensures that container images are pulled only from approved registries.
- **Message**: "Unknown image registry."
- **Approved Registries**:
  - starkregistry.azurecr.io
  - docker.io

## Policy Details
- **Validation Failure Action**: audit
- **Background**: true

## Target Resources
- Kinds: Pod

## How to Use
1. Apply this policy to your Kubernetes cluster using : `kubectl apply -f restrict-img-reg`
2. The policy will audit all existing and new Pods to ensure they use images from approved registries.

## Additional Notes
- This policy is set to 'audit' mode. To enforce the policy, change `validationFailureAction` to 'enforce'.
- Customize the list of approved registries in the policy YAML to match your organization's requirements.
- Ensure that all necessary images are available in the approved registries before enforcing this policy.
