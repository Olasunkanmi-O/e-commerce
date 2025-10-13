#!/bin/bash
set -e

# === Configuration ===
AWS_REGION="eu-west-2"
#AWS_PROFILE="pet-adoption"

# Buckets
TERRAFORM_BUCKET="ecommerce-project-1232"
KOPS_BUCKET="ecommerce-kops-state-1232"

# Jenkins folder
JENKINS_DIR="Jenkins"

# Function to create an S3 bucket with versioning
create_s3_bucket() {
  local BUCKET_NAME=$1
  echo "Creating S3 bucket: $BUCKET_NAME..."
  aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$AWS_REGION" \
    --create-bucket-configuration LocationConstraint="$AWS_REGION"
  aws s3api put-bucket-versioning --bucket "$BUCKET_NAME" --region "$AWS_REGION" \
    --versioning-configuration Status=Enabled
  echo "Bucket $BUCKET_NAME created and versioning enabled."
  echo "--------------------------------------------"
}

# Function to delete all objects and the bucket
delete_s3_bucket() {
  local BUCKET_NAME=$1
  echo "Deleting all objects in bucket: $BUCKET_NAME..."

  DELETE_LIST=$(aws s3api list-object-versions \
    --bucket "$BUCKET_NAME" \
    --profile "$AWS_PROFILE" \
    --region "$AWS_REGION" \
    --output json)

  OBJECTS_TO_DELETE=$(echo "$DELETE_LIST" | jq '{
    Objects: (
      [.Versions[]?, .DeleteMarkers[]?]
      | map({Key: .Key, VersionId: .VersionId})
    ),
    Quiet: true
  }')

  NUM_OBJECTS=$(echo "$OBJECTS_TO_DELETE" | jq '.Objects | length')

  if [ "$NUM_OBJECTS" -gt 0 ]; then
    echo "Deleting $NUM_OBJECTS objects from bucket: $BUCKET_NAME..."
    aws s3api delete-objects \
      --bucket "$BUCKET_NAME" \
      --delete "$OBJECTS_TO_DELETE" \
      --region "$AWS_REGION" \
      --profile "$AWS_PROFILE"
    echo "Objects deleted successfully."
  else
    echo "No objects or versions found in $BUCKET_NAME."
  fi

  echo "Deleting bucket: $BUCKET_NAME..."
  aws s3api delete-bucket \
    --bucket "$BUCKET_NAME" \
    --region "$AWS_REGION" \
    --profile "$AWS_PROFILE"
  echo "Bucket $BUCKET_NAME deleted successfully."
  echo "--------------------------------------------"
}

# === Main Workflow ===
ACTION=$1

if [[ "$ACTION" == "create" ]]; then
  echo "=== Creating infrastructure ==="
  
  # Create S3 buckets
  create_s3_bucket "$TERRAFORM_BUCKET"
  create_s3_bucket "$KOPS_BUCKET"

  # Setup Jenkins via Terraform
  echo "Setting up Jenkins server..."
  cd "$JENKINS_DIR"
  terraform init
  terraform validate
  terraform apply -auto-approve
  cd ..

elif [[ "$ACTION" == "destroy" ]]; then
  echo "=== Destroying infrastructure ==="
  
  # Destroy Jenkins via Terraform
  echo "Destroying Jenkins server..."
  cd "$JENKINS_DIR"
  terraform init
  terraform destroy -auto-approve
  cd ..

  # Delete buckets
  delete_s3_bucket "$TERRAFORM_BUCKET"
  delete_s3_bucket "$KOPS_BUCKET"

else
  echo "Usage: $0 [create|destroy]"
  exit 1
fi

echo "=== Workflow completed successfully ==="
