#!/bin/bash

FILE_NAME=$(readlink -f "$0")
SCRIPTS_DIR=$(dirname "${FILE_NAME}")
ROOT_DIR=${SCRIPTS_DIR}/..
LOG_DIR=${ROOT_DIR}/log
APP_DIR=${ROOT_DIR}/env_configurator
BUILD_DIR=${ROOT_DIR}/build
DIST_DIR=${ROOT_DIR}/dist
CONFIG_DIR=${1}

source ${SCRIPTS_DIR}/utils.sh

print -si "Run project..."

RUN_LOG=${LOG_DIR}/run.log
echo "" > ${RUN_LOG}

chmod +x ${DIST_DIR}/env_configurator  >> ${RUN_LOG} 2>&1
${DIST_DIR}/env_configurator ${CONFIG_DIR} 2>> ${RUN_LOG}
RET=$?

if [ ${RET} -eq 0 ]; then
    print -s "App exited with success"
    echo
    exit 0
elif [ ${RET} -eq 100 ]; then
    echo
    print -si "The app has been interrupted"
    exit 100
else 
    print -se "App exited with error: ${RET}"
    print -si "Check '${RUN_LOG}' for more informations"
    exit 3
fi