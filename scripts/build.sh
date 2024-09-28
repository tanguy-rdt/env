#!/bin/bash

FILE_NAME=$(readlink -f "$0")
SCRIPTS_DIR=$(dirname "${FILE_NAME}")
ROOT_DIR=${SCRIPTS_DIR}/..
LOG_DIR=${ROOT_DIR}/log
APP_DIR=${ROOT_DIR}/app
BUILD_DIR=${ROOT_DIR}/build
DIST_DIR=${ROOT_DIR}/dist

source ${SCRIPTS_DIR}/utils.sh

print -si "Building project..."

BUILD_LOG=${LOG_DIR}/build.log
echo "" > ${BUILD_LOG}

cmake -GNinja -S ${APP_DIR} -B ${BUILD_DIR} >> ${BUILD_LOG} 2>&1
RET=$?

ninja -C ${BUILD_DIR} >> ${BUILD_LOG} 2>&1
RET=$?

if [ ${RET} -eq 0 ]; then
    print -s "Build succeed, dist dir: ${DIST_DIR}"
    echo
    exit 0
else 
    print -se "Build failed"
    print -si "Check '${BUILD_LOG}' for more informations"
    exit 2
fi