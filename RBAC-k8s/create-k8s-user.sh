#!/bin/bash

# Prompt for variables
read -p "Enter Service Account Name (default: devops-cluster-admin): " SERVICE_ACCOUNT_NAME
SERVICE_ACCOUNT_NAME=${SERVICE_ACCOUNT_NAME:-devops-cluster-admin}

read -p "Enter Namespace (default: kube-system): " NAMESPACE
NAMESPACE=${NAMESPACE:-kube-system}

read -p "Enter Kubeconfig File Name (default: devops-cluster-admin-config): " KUBECONFIG_FILE
KUBECONFIG_FILE=${KUBECONFIG_FILE:-devops-cluster-admin-config}

# Define other variables
SECRET_NAME="${SERVICE_ACCOUNT_NAME}-secret"
CLUSTER_ROLE_NAME="${SERVICE_ACCOUNT_NAME}"
CLUSTER_ROLE_BINDING_NAME="${SERVICE_ACCOUNT_NAME}"

# Step 1: Create a Service Account
kubectl -n $NAMESPACE create serviceaccount $SERVICE_ACCOUNT_NAME

# Step 2: Create a Secret Object for the Service Account
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: $SECRET_NAME
  namespace: $NAMESPACE
  annotations:
    kubernetes.io/service-account.name: $SERVICE_ACCOUNT_NAME
type: kubernetes.io/service-account-token
EOF

# Step 3: Create a ClusterRole
cat << EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: $CLUSTER_ROLE_NAME
rules:
- apiGroups: [""]
  resources:
  - nodes
  - nodes/proxy
  - services
  - endpoints
  - pods
  verbs: ["get", "list", "watch"]
- apiGroups:
  - extensions
  resources:
  - ingresses
  verbs: ["get", "list", "watch"]
EOF

# Step 4: Create ClusterRoleBinding
cat << EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: $CLUSTER_ROLE_BINDING_NAME
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: $CLUSTER_ROLE_NAME
subjects:
- kind: ServiceAccount
  name: $SERVICE_ACCOUNT_NAME
  namespace: $NAMESPACE
EOF

# Step 5: Get all Cluster Details & Secrets
SA_SECRET_TOKEN=$(kubectl -n $NAMESPACE get secret/$SECRET_NAME -o go-template='{{.data.token}}' | base64 --decode)
CLUSTER_NAME=$(kubectl config current-context)
CURRENT_CLUSTER=$(kubectl config view --raw -o go-template='{{range .contexts}}{{if eq .name "'"${CLUSTER_NAME}"'"}}{{ index .context "cluster" }}{{end}}{{end}}')
CLUSTER_CA_CERT=$(kubectl config view --raw -o go-template='{{range .clusters}}{{if eq .name "'"${CURRENT_CLUSTER}"'"}}{{ index .cluster "certificate-authority-data" }}{{end}}{{end}}')
CLUSTER_ENDPOINT=$(kubectl config view --raw -o go-template='{{range .clusters}}{{if eq .name "'"${CURRENT_CLUSTER}"'"}}{{ .cluster.server }}{{end}}{{end}}')

# Step 6: Generate the Kubeconfig with the variables
cat << EOF > $KUBECONFIG_FILE
apiVersion: v1
kind: Config
current-context: ${CLUSTER_NAME}
contexts:
- name: ${CLUSTER_NAME}
  context:
    cluster: ${CLUSTER_NAME}
    user: $SERVICE_ACCOUNT_NAME
clusters:
- name: ${CLUSTER_NAME}
  cluster:
    certificate-authority-data: ${CLUSTER_CA_CERT}
    server: ${CLUSTER_ENDPOINT}
users:
- name: $SERVICE_ACCOUNT_NAME
  user:
    token: ${SA_SECRET_TOKEN}
EOF

echo "Kubeconfig file created: $KUBECONFIG_FILE"

# Inform the user about copying the file and updating bashrc
echo -e "\033[33mTo use the kubeconfig file, follow these steps:\033[0m"
echo -e "\033[33m1. Copy the kubeconfig file to the host with kubectl using scp:\033[0m"
echo -e "\033[33m   scp $KUBECONFIG_FILE username@ip:/destination\033[0m"
echo -e "\033[33m2. On the host, add the following line to your bashrc file to use the kubeconfig:\033[0m"
echo -e "\033[33m   export KUBECONFIG=/destination/$KUBECONFIG_FILE\033[0m"
echo -e "\033[33m   (replace /destination/$KUBECONFIG_FILE with the actual path where you copied the kubeconfig file)\033[0m"
echo -e "\033[33m3. Source the bashrc file to apply the changes:\033[0m"
echo -e "\033[33m   source ~/.bashrc\033[0m"
