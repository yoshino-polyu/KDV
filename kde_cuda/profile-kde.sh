#!/bin/bash

# Path to the Nsight Compute executable
NCU_PATH="/usr/local/cuda/bin/ncu"

# Directory containing this script (for output files)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Path to run script (default or from command line)
RUN_SCRIPT="${SCRIPT_DIR}/run_kde_cuda_kdtr.sh"
if [ "$1" != "" ] && [ -f "$1" ]; then
    RUN_SCRIPT="$1"
    shift
fi

# Check if run script exists
if [ ! -f "$RUN_SCRIPT" ]; then
    echo "Error: Run script $RUN_SCRIPT not found!"
    exit 1
fi

# Extract executable and arguments from run script
CMD_LINE=$(grep -o "sh -c \".*\"" "$RUN_SCRIPT" | sed 's/sh -c "\(.*\)"/\1/;s/\s*>.*$//')

if [ -z "$CMD_LINE" ]; then
    # Try alternative format without sh -c wrapper
    CMD_LINE=$(grep -o "build/bin/[^ ]*.*" "$RUN_SCRIPT" | sed 's/\s*>.*$//')
fi

if [ -z "$CMD_LINE" ]; then
    echo "Error: Could not extract command line from $RUN_SCRIPT"
    exit 1
fi

# Extract executable path (everything before the first space)
EXECUTABLE_PATH=$(echo "$CMD_LINE" | awk '{print $1}')
EXECUTABLE=$(basename "$EXECUTABLE_PATH")
CMD_ARGS=$(echo "$CMD_LINE" | cut -d' ' -f2-)

# Override with command line arguments if provided
if [ "$1" != "" ]; then
    CMD_ARGS="$@"
fi

echo "Run script: $RUN_SCRIPT"
echo "Extracted executable: $EXECUTABLE_PATH"
echo "Executable name: $EXECUTABLE"
echo "Command arguments: $CMD_ARGS"

# Check if executable exists
if [ ! -f "$EXECUTABLE_PATH" ]; then
    # Try with CUDA_BIN_DIR prefix if path is relative
    CUDA_BIN_DIR="${SCRIPT_DIR}/build/bin"
    if [[ "$EXECUTABLE_PATH" != /* ]] && [[ "$EXECUTABLE_PATH" != *"/"* ]]; then
        EXECUTABLE_PATH="${CUDA_BIN_DIR}/${EXECUTABLE_PATH}"
    fi
    
    if [ ! -f "$EXECUTABLE_PATH" ]; then
        echo "Error: Executable $EXECUTABLE_PATH not found!"
        echo "Available executables in ${CUDA_BIN_DIR}:"
        ls -la ${CUDA_BIN_DIR} 2>/dev/null || echo "Directory not found"
        exit 1
    fi
fi

# Create output filenames based on executable name and timestamp
TIMESTAMP=$(date +'%Y%m%d_%H%M%S')
OUTPUT_NCU_REP="${SCRIPT_DIR}/${EXECUTABLE}_${TIMESTAMP}.ncu-rep"
OUTPUT_LOG="${SCRIPT_DIR}/${EXECUTABLE}_${TIMESTAMP}.log"

echo "Profiling ${EXECUTABLE_PATH} with arguments: ${CMD_ARGS}"
echo "Output will be saved to ${OUTPUT_NCU_REP}"

# Run the profiling command
${NCU_PATH} --config-file off \
    --export "${OUTPUT_NCU_REP}" \
    --force-overwrite \
    --set full \
    --import-source yes \
    "${EXECUTABLE_PATH}" ${CMD_ARGS} > "${OUTPUT_LOG}" 2>&1

echo "Profiling completed. Log saved to ${OUTPUT_LOG}"