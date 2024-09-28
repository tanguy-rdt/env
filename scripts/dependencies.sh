#!/bin/bash

FILE_NAME=$(readlink -f "$0")
SCRIPTS_DIR=$(dirname "${FILE_NAME}")
ROOT_DIR=${SCRIPTS_DIR}/..
LOG_DIR=${ROOT_DIR}/log
CONFIG_DIR=${1}

source ${SCRIPTS_DIR}/utils.sh

print -si "Checking dependencies..."

DEPENDENCIES_LOG=${LOG_DIR}/dependencies.log
echo "" > ${DEPENDENCIES_LOG}

if [ ! -f "${CONFIG_DIR}/dependencies.json" ]; then
    print -se "${CONFIG_DIR}/dependencies.json not found"
    exit 1
fi

OLD_IFS="$IFS"
IFS=$'\n'
DEPENDENCIES_NAME=($(jq -r '.dependencies[].name' "${CONFIG_DIR}/dependencies.json"))
DEPENDENCIES_INSTALL_CMD=($(jq -r '.dependencies[].install_command' "${CONFIG_DIR}/dependencies.json"))
DEPENDENCIES_CHECK_CMD=($(jq -r '.dependencies[].check_command' "${CONFIG_DIR}/dependencies.json"))
DEPENDENCIES_EXPECTED_RES=($(jq -r '.dependencies[].expected_result' "${CONFIG_DIR}/dependencies.json"))
IFS="$OLD_IFS"

DEPENDENCIES_TO_INSTALL_NAME=()
DEPENDENCIES_TO_INSTALL_CMD=()
for i in $(seq 0 $((${#DEPENDENCIES_CHECK_CMD[@]}-1))); do
    eval ${DEPENDENCIES_CHECK_CMD[${i}]}  > /dev/null 2>&1

    if [ $? -ne ${DEPENDENCIES_EXPECTED_RES[${i}]} ]; then
        DEPENDENCIES_TO_INSTALL_NAME+=("${DEPENDENCIES_NAME[${i}]}")
        DEPENDENCIES_TO_INSTALL_CMD+=("${DEPENDENCIES_INSTALL_CMD[${i}]}")
    fi
done

if [ -n "${DEPENDENCIES_TO_INSTALL_NAME}" ]; then 
    while true; do
        print -snw "The dependencies '${DEPENDENCIES_TO_INSTALL_NAME[@]}' need to be installed. Are you agree ? [y/n]: "
        read -n1 yn
        yn=${yn:-y}
        echo
        case "${yn,,}" in 
            y|yes)
                break
                ;;
            n|no)
                print -si "You need to install the dependencies '${DEPENDENCIES_TO_INSTALL_NAME[@]}' to continue"
                exit 0
                ;;
            *)
                ;;
        esac
    done

    root_privilege

    MISSING_DEPENDENCIES=()
    for i in $(seq 0 $((${#DEPENDENCIES_TO_INSTALL_NAME[@]}-1))); do
        print -ni "-- Installing '${DEPENDENCIES_TO_INSTALL_NAME[${i}]}'..."
        eval ${DEPENDENCIES_TO_INSTALL_CMD[${i}]} >> ${DEPENDENCIES_LOG} 2>&1
        
        if [ $? -eq 0 ]; then 
            print -s "SUCCESS"
        else 
            print -e "ERROR"
            MISSING_DEPENDENCIES+=(${DEPENDENCIES_TO_INSTALL_NAME[${i}]})
        fi
    done
fi

if [ ${#MISSING_DEPENDENCIES[@]} -eq 0 ]; then
    print -s "All the dependencies are installed"
    echo
    exit 0
else 
    print -se "The following dependencies is missing: '${MISSING_DEPENDENCIES[@]}'"
    print -si "Check '${DEPENDENCIES_LOG}' for more informations"
    exit 1
fi