#!/usr/bin/env bash

set -euo pipefail

show_help() {
  cat <<EOF
Helmfile Deploy Script

Usage:
  ./helmfile-apply.sh <environment> [release-name]

Examples:
  ./helmfile-apply.sh dev                 # Deploy all releases to dev
  ./helmfile-apply.sh prod service-a     # Deploy only 'service-a' to prod
  ./helmfile-apply.sh staging redis      # Deploy redis to staging

Options:
  -h, --help    Show this help message and exit

Environment values must match the directories in your 'environments/' folder.
EOF
}

# Help flag
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  show_help
  exit 0
fi

# Validate input
if [[ $# -lt 1 ]]; then
  echo "ERROR: Environment is required."
  show_help
  exit 1
fi

ENVIRONMENT=$1
RELEASE_NAME=${2:-}

echo "Deploying to environment: $ENVIRONMENT"

CMD="helmfile -e $ENVIRONMENT"

if [[ -n "$RELEASE_NAME" ]]; then
  echo "Targeting release: $RELEASE_NAME"
  CMD="$CMD -l name=$RELEASE_NAME"
fi

$CMD apply
