#!/bin/bash

# Exit on any error
set -e

# Configure the build with CUDA_ENABLE_LINEINFO=ON
echo "Configuring CMake build with CUDA_ENABLE_LINEINFO=ON..."
cmake -DCUDA_ENABLE_LINEINFO=ON -B build -S .

# Build the project using available processors
echo "Building with $(nproc) threads..."
cmake --build build -j $(nproc)

echo "Build completed successfully!"