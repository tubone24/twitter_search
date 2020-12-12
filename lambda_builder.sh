#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname $0) || exit; pwd)
WORKSPACE=${SCRIPT_DIR}/workspace
SRC_DIR=${SCRIPT_DIR}/src

######################################
# Create Temp Workspace
######################################
if [ -d "${WORKSPACE}" ]; then
    rm -rf "${WORKSPACE}"
fi
mkdir "${WORKSPACE}"

pip3 install -r "${SCRIPT_DIR}"/requirements.txt -t "${WORKSPACE}"/lib
cp -rf "${SRC_DIR}"/* "${WORKSPACE}"
