#!/bin/bash

# set variable for bucket-name
BUCKET_NAME="ecommerce-project-1232"  # general bucket for the terraform state 
KOPS_BUCKET="ecommerce-kops-state-1232"  # kops bucket for kuberenetes cluster
AWS_REGION="eu-west-2"  # region to deploy 

# create bucket
aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$AWS_REGION" --profile "$AWS_PROFILE" \
  --create-bucket-configuration LocationConstraint="$AWS_REGION"
# enable versioning
aws s3api put-bucket-versioning --bucket "$BUCKET_NAME" --region "$AWS_REGION" --profile "$AWS_PROFILE" \
  --versioning-configuration Status=Enabled

# Create Kops state bucket
aws s3api create-bucket --bucket "$KOPS_BUCKET" --region "$AWS_REGION" \
  --create-bucket-configuration LocationConstraint="$AWS_REGION"
# enable versioning  
aws s3api put-bucket-versioning --bucket "$KOPS_BUCKET" --region "$AWS_REGION" \
  --versioning-configuration Status=Enabled

echo "Creating Jenkins Server"
cd jenkins
terraform init 
terraform validate
terraform apply -auto-approve