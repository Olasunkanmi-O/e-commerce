#!/bin/bash
set -e

KOPS_STATE_STORE=${KOPS_STATE_STORE:-s3://my-kops-state-store}
CLUSTER_NAME=${CLUSTER_NAME:-ecommerce.k8s.local}

echo "Validating cluster readiness..."
kops validate cluster --name $CLUSTER_NAME --state $KOPS_STATE_STORE --wait 15m

kubectl get nodes -o wide
kubectl get pods -A || true

echo "Cluster validated successfully ✅"
