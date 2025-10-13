#!/bin/bash
set -e

KOPS_STATE_STORE=${KOPS_STATE_STORE:-s3://my-kops-state-store}
CLUSTER_NAME=${CLUSTER_NAME:-ecommerce.k8s.local}

echo "Deleting cluster $CLUSTER_NAME ..."
kops delete cluster --name $CLUSTER_NAME --state $KOPS_STATE_STORE --yes

echo "Cluster deleted successfully 🧹"
