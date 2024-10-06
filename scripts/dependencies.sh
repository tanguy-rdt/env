#!/bin/bash

FILE_NAME=$(readlink -f "$0")
SCRIPTS_DIR=$(dirname "${FILE_NAME}")
ROOT_DIR=${SCRIPTS_DIR}/..
LOG_DIR=${ROOT_DIR}/log
CONFIG_DIR=${1}
TOML_FILE=${CONFIG_DIR}/dependencies.toml

source ${SCRIPTS_DIR}/utils.sh

print -si "Checking dependencies..."

DEPENDENCIES_LOG=${LOG_DIR}/dependencies.log
echo "" > ${DEPENDENCIES_LOG}

if [ ! -f "${TOML_FILE}" ]; then
    print -se "${TOML_FILE} not found"
    exit 1
fi

DEPENDENCIES_NAME=()
DEPENDENCIES_INSTALL_CMD=()
DEPENDENCIES_CHECK_CMD=()
DEPENDENCIES_EXPECTED_RES=()

while IFS= read -r LINE; do
    if [[ "${LINE}" =~ \[\[dependencies\]\] ]]; then
        read -r NAME_LINE
        if [[ $NAME_LINE =~ name\ =\ \"([^\"]+)\" ]]; then
            DEPENDENCIES_NAME+=("${BASH_REMATCH[1]}")
        else 
            print -se "Unable to parse ${TOML_FILE}, incorrect syntax in 'name' at dependency ${DEPENDENCIES_HOVERED}"
            exit 2
        fi

        read -r INSTALL_CMD_LINE
        if [[ $INSTALL_CMD_LINE =~ install_command\ =\ \"(.*)\" ]]; then
            DEPENDENCIES_INSTALL_CMD+=("${BASH_REMATCH[1]}")
        else 
            print -se "Unable to parse ${TOML_FILE}, incorrect syntax in 'install_command' at dependency ${DEPENDENCIES_HOVERED}"
            exit 3
        fi

        read -r CHECK_CMD_LINE
        if [[ $CHECK_CMD_LINE =~ check_command\ =\ \"(.*)\" ]]; then
            DEPENDENCIES_CHECK_CMD+=("${BASH_REMATCH[1]}")
        else 
            print -se "Unable to parse ${TOML_FILE}, incorrect syntax in 'check_command' at dependency ${DEPENDENCIES_HOVERED}"
            exit 4
        fi

        read -r EXPECTED_RESULT_LINE
        if [[ $EXPECTED_RESULT_LINE =~ expected_result\ =\ ([0-9]+) ]]; then
            DEPENDENCIES_EXPECTED_RES+=("${BASH_REMATCH[1]}")
        else 
            print -se "Unable to parse ${TOML_FILE}, incorrect syntax in 'expected_result' at dependency ${DEPENDENCIES_HOVERED}"
            exit 5
        fi
    fi
done < "$TOML_FILE"

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
                exit 6
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
    exit 7
fi