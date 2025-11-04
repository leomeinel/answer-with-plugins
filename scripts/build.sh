#!/usr/bin/env bash
###
# File: build.sh
# Author: Leopold Meinel (leo@meinel.dev)
# -----
# Copyright (c) 2025 Leopold Meinel & contributors
# SPDX ID: MIT
# URL: https://opensource.org/licenses/MIT
# -----
###

# Fail on error
set -e

# Set ${SCRIPT_DIR}
SCRIPT_DIR="$(dirname -- "$(readlink -f -- "${0}")")"

# Check if ${PLUGIN_FILE} exists
PLUGIN_FILE=${SCRIPT_DIR}/plugins.txt
if [[ ! -f ${PLUGIN_FILE} ]]; then
    echo "ERROR: 'PLUGIN_FILE' does not exist."
    exit 1
fi

# APPEND COMMAND with repositories from ${PLUGIN_FILE}
OUTPUT=/usr/bin/new_answer
COMMAND="/usr/bin/answer build --output ${OUTPUT}"
while IFS= read -r repo; do
    COMMAND+=" --with ${repo}"
done < <(grep -v '^ *#' "${PLUGIN_FILE}")

# Execute ${COMMAND}
echo "COMMAND is: '${COMMAND}'"
${COMMAND}

# Check ${OUTPUT}
if [[ ! -f ${OUTPUT} ]]; then
    echo "ERROR: '${OUTPUT}' does not exist. The build was unsuccessful."
    exit 1
fi
