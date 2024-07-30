# Require Pod Probes Policy

## Overview
- **Policy Name**: require-pod-probes
- **Category**: Best Practices
- **Severity**: Medium
- **Subject**: Pod

## Description
Liveness and readiness probes need to be configured to correctly manage a Pod's lifecycle during deployments, restarts, and upgrades. For each Pod, a periodic `livenessProbe` is performed by the kubelet to determine if the Pod's containers are running or need to be restarted. A `readinessProbe` is used by Services and Deployments to determine if the Pod is ready to receive network traffic. This policy validates that all containers have one of livenessProbe, readinessProbe, or startupProbe defined.

## Rules

### 1. Validate Probes
- **Name**: validate-probes
- **Description**: Ensures that each container in a Pod has at least one type of probe defined.
- **Message**: "Liveness, readiness, or startup probes are required for all containers."

## Policy Details
- **Validation Failure Action**: enforce
- **Background**: true

## Target Resources
- Kinds: Pod

## Preconditions
- Applies to CREATE and UPDATE operations

## How to Use
1. Apply this policy to your Kubernetes cluster using : `kubectl apply -f require-pod-probes.yml`
2. The policy will enforce probe requirements for all new and updated Pods.

## Validation Logic
The policy checks each container in a Pod and denies the request if all of the following conditions are true:
- No livenessProbe is defined
- No startupProbe is defined
- No readinessProbe is defined

