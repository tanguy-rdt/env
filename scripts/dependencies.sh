#!/bin/bash

FILE_NAME=$(readlink -f "$0")
SCRIPTS_DIR=$(dirname "${FILE_NAME}")
ROOT_DIR=${SCRIPTS_DIR}/..
CONFIG_DIR=${1}
TOML_FILE=${CONFIG_DIR}/dependencies.toml
LOG_FILE=${ROOT_DIR}/log/dependencies.log

source ${SCRIPTS_DIR}/utils.sh

print -si "Checking dependencies..."

echo "" > ${LOG_FILE}

chmod +x ${SCRIPTS_DIR}/toml_job_runner.sh
${SCRIPTS_DIR}/toml_job_runner.sh ${TOML_FILE} ${LOG_FILE}
RET=$? 

if [ ${RET} -eq 0 ]; then
    echo
    print -s "All the dependencies are installed"
    echo
    exit 0
elif [ ${RET} -eq 100 ]; then
    echo
    print -si "The jobs runner has been interrupted, you must accept to continue"
    exit 100
else 
    print -se "${RET} Dependencies is missing"
    print -si "Check '${LOG_FILE}' for more informations"
    exit 1
fi