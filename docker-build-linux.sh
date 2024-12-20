#!/bin/bash

sudo rm -rf build bundled
# Define the target for the build (Debug or Release)
TARGET="${1:-Debug}"

docker run -v "$(pwd)":/build/komodo-wallet-desktop --privileged -v /dev/fuse:/dev/fuse \
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
  echo "Make sure you run 'docker build -t kw-build-container .' first"
  exit 1
fi

sudo chown $USER:$USER bundled -R
