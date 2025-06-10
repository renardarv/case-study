#!/bin/bash

# Usage: ./apply.sh <workspace> <target> <terraform_directory>

WORKSPACE="$1"
TARGET="$2"
TF_DIR="$3"

# Validate input
if [[ -z "$WORKSPACE" || -z "$TARGET" || -z "$TF_DIR" ]]; then
  echo "Usage: $0 <workspace> <target> <terraform_directory>"
  echo "Example: $0 dev module.vpc terraform/environments/dev"
  exit 1
fi

# Initialize Terraform in specified directory
terraform -chdir="$TF_DIR" init -upgrade

# Select or create the workspace
terraform -chdir="$TF_DIR" workspace select "$WORKSPACE" 2>/dev/null || terraform -chdir="$TF_DIR" workspace new "$WORKSPACE"

# Apply only the specified target
terraform -chdir="$TF_DIR" apply -target="$TARGET" -auto-approve
