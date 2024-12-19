#!/bin/bash

# Define the Docker Compose service to run
SERVICE="kw-build"

# Define the target for the build (Debug or Release)
TARGET="Debug"

# Run Docker Compose and capture logs
docker-compose run --rm \
  -w /build/komodo-wallet-desktop/ci_tools_atomic_dex $SERVICE \
  bash -c "./ci_tools_atomic_dex build $TARGET" 2>&1 | tee build.log

# Check if the build was successful
if [ "${PIPESTATUS[0]}" -eq 0 ]; then
  echo "Build completed successfully!"
else
  echo "Build failed. Check build.log for details."
  echo "Make sure you run 'docker build -t kw-build-container -f .docker/Dockerfile .' first"
  exit 1
fi
