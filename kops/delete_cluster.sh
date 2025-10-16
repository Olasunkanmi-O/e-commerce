#!/bin/bash
set -e

KOPS_STATE_STORE=${KOPS_STATE_STORE:-s3://ecommerce-kops-state-1232}
CLUSTER_NAME=${CLUSTER_NAME:-ecommerce.alasoasiko.co.uk}

echo "Deleting cluster $CLUSTER_NAME ..."
kops delete cluster --name $CLUSTER_NAME --state $KOPS_STATE_STORE --yes

echo "Cluster deleted successfully "
