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
        DEPENDENCIES_HOVERED=$((DEPENDENCIES_HOVERED + 1))
        for i in {0..3}; do
            read -r DEPENDENCY_INFO_LINE

            if [[ $DEPENDENCY_INFO_LINE =~ name\ =\ \'(.*)\' ]]; then
                DEPENDENCIES_NAME+=("${BASH_REMATCH[1]}")
            elif [[ $DEPENDENCY_INFO_LINE =~ install_command\ =\ \'(.*)\' ]]; then
                DEPENDENCIES_INSTALL_CMD+=("${BASH_REMATCH[1]}")
            elif [[ $DEPENDENCY_INFO_LINE =~ check_command\ =\ \'(.*)\' ]]; then
                DEPENDENCIES_CHECK_CMD+=("${BASH_REMATCH[1]}")
            elif [[ $DEPENDENCY_INFO_LINE =~ expected_result\ =\ ([0-9]+) ]]; then
                DEPENDENCIES_EXPECTED_RES+=("${BASH_REMATCH[1]}")
            else 
                print -se "Unable to parse ${TOML_FILE}, incorrect syntax at dependency ${DEPENDENCIES_HOVERED}"
                exit 2
            fi
        done
    fi
done < "$TOML_FILE"

if [[ ${#DEPENDENCIES_NAME[@]} -ne ${#DEPENDENCIES_INSTALL_CMD[@]} || \
      ${#DEPENDENCIES_NAME[@]} -ne ${#DEPENDENCIES_CHECK_CMD[@]} || \
      ${#DEPENDENCIES_NAME[@]} -ne ${#DEPENDENCIES_EXPECTED_RES[@]} ]]; then
    print -se "Some information is missing from the dependencies declaration"
    exit 3
fi

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
                exit 4
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
    exit 5
fi