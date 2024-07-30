# Disallow Latest Tag Policy

## Overview
- **Policy Name**: disallow-latest-tag
- **Category**: Best Practices
- **Severity**: Medium
- **Subject**: Pod
- **Version**: kyverno.io/v1

## Description
This policy enforces best practices for container image tagging in Kubernetes Pods. The ':latest' tag is mutable and can lead to unexpected errors if the image changes. A best practice is to use an immutable tag that maps to a specific version of an application Pod. This policy validates that the image specifies a tag and that it is not called `latest`.

## Rules

### 1. Require Image Tag
- **Name**: require-image-tag
- **Description**: Ensures that all container images have a specified tag.
- **Message**: "An image tag is required."

### 2. Validate Image Tag
- **Name**: validate-image-tag
- **Description**: Prevents the use of the 'latest' tag for container images.
- **Message**: "Using a mutable image tag e.g. 'latest' is not allowed."

## Policy Details
- **Validation Failure Action**: audit
- **Background**: true

## Target Resources
- Kinds: Pod

## How to Use
1. Apply this policy to your Kubernetes cluster using : `kubectl apply -f disallow-lts-tag.yml`
