#!/bin/bash

# Define the target for the build (Debug or Release)
TARGET="${1:-Debug}"

docker run -v "$(pwd)":/build/komodo-wallet-desktop \
    kw-build-container \
    bash -c  "cd /build/komodo-wallet-desktop/ci_tools_atomic_dex && \
        nimble build -y && \
        ./ci_tools_atomic_dex build $TARGET && \
        ./ci_tools_atomic_dex bundle $TARGET" 2>&1 | tee build.log

# Check if the build was successful
if [ "${PIPESTATUS[0]}" -eq 0 ]; then
  echo "Build completed successfully!"
else
  echo "Build failed. Check build.log for details."
  echo "Make sure you run 'docker build -t kw-build-container -f .docker/Dockerfile .' first"
  exit 1
fi
