#!/bin/bash
# builds and pushes docker kong image
# Usage: scripts/push_image.sh [TAG] (defaults to using <DATE>-<GIT_SHORT_HASH>)
TAG=$1

set -euo pipefail

if [ -z "$TAG" ]; then
  TAG="latest"
  echo "Release tag: ${TAG}"
fi

AWS_REGION="us-east-1"
AWS_ACCOUNT_ID="$(aws sts get-caller-identity --output text --query 'Account')"
eval $(aws ecr get-login --no-include-email --region ${AWS_REGION} | sed 's|https://||')

URL="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/kong:${TAG}"
docker pull kong:$TAG

docker tag kong:$TAG $URL
docker push $URL


echo "built and pushed $URL"
