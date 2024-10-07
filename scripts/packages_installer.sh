#!/bin/bash

FILE_NAME=$(readlink -f "$0")
SCRIPTS_DIR=$(dirname "${FILE_NAME}")
ROOT_DIR=${SCRIPTS_DIR}/..
LOG_DIR=${ROOT_DIR}/log
CONFIG_DIR=${1}
TOML_FILE=${CONFIG_DIR}/config_generated.toml

source ${SCRIPTS_DIR}/utils.sh

print -si "Install generated configuration ..."

PACKAGES_LOG=${LOG_DIR}/config_generated_installer.log
echo "" > ${PACKAGES_LOG}

if [ ! -f "${TOML_FILE}" ]; then
    print -se "${TOML_FILE} not found"
    exit 1
fi

PACKAGES_NAME=()
PACKAGES_INSTALL_CMD=()
PACKAGES_CHECK_CMD=()
PACKAGES_EXPECTED_RES=()
PACKAGES_HOVERED=0
while IFS= read -r LINE; do
    if [[ "${LINE}" =~ \[\[package\]\] ]]; then
        PACKAGES_HOVERED=$((PACKAGES_HOVERED + 1))
        for i in {0..3}; do
            read -r PACKAGE_INFO_LINE

            if [[ $PACKAGE_INFO_LINE =~ name\ =\ \'(.*)\' ]]; then
                PACKAGES_NAME+=("${BASH_REMATCH[1]}")
            elif [[ $PACKAGE_INFO_LINE =~ install_command\ =\ \'(.*)\' ]]; then
                PACKAGES_INSTALL_CMD+=("${BASH_REMATCH[1]}")
            elif [[ $PACKAGE_INFO_LINE =~ check_command\ =\ \'(.*)\' ]]; then
                PACKAGES_CHECK_CMD+=("${BASH_REMATCH[1]}")
            elif [[ $PACKAGE_INFO_LINE =~ expected_result\ =\ ([0-9]+) ]]; then
                PACKAGES_EXPECTED_RES+=("${BASH_REMATCH[1]}")
            fi
        done
    fi
done < "$TOML_FILE"

if [[ ${#PACKAGES_NAME[@]} -ne ${#PACKAGES_INSTALL_CMD[@]} || \
      ${#PACKAGES_NAME[@]} -ne ${#PACKAGES_CHECK_CMD[@]} || \
      ${#PACKAGES_NAME[@]} -ne ${#PACKAGES_EXPECTED_RES[@]} ]]; then
    print -se "Some information is missing from the package declaration"
    print -e "\t Number of 'name' found ${#PACKAGES_NAME[@]}"
    print -e "\t Number of 'install_command' found ${#PACKAGES_INSTALL_CMD[@]}"
    print -e "\t Number of 'check_command' found ${#PACKAGES_CHECK_CMD[@]}"
    print -e "\t Number of 'expected_result' found ${#PACKAGES_EXPECTED_RES[@]}"

    exit 3
fi

PACKAGES_TO_INSTALL_NAME=()
PACKAGES_TO_INSTALL_CMD=()
for i in $(seq 0 $((${#PACKAGES_CHECK_CMD[@]}-1))); do
    eval ${PACKAGES_CHECK_CMD[${i}]}  > /dev/null 2>&1

    if [ $? -ne ${PACKAGES_EXPECTED_RES[${i}]} ]; then
        PACKAGES_TO_INSTALL_NAME+=("${PACKAGES_NAME[${i}]}")
        PACKAGES_TO_INSTALL_CMD+=("${PACKAGES_INSTALL_CMD[${i}]}")
    fi
done

if [ -n "${PACKAGES_TO_INSTALL_NAME}" ]; then 
    print -snw "The packages '${PACKAGES_TO_INSTALL_NAME[@]}' need to be installed. Are you agree ? [y/n]: "
    read -n1 yn
    yn=${yn:-y}
    echo
    case "${yn,,}" in 
        y|yes)
            ;;
        n|no)
            exit 4
            ;;
        *)
            ;;
    esac

    root_privilege

    MISSING_PACKAGES=()
    for i in $(seq 0 $((${#PACKAGES_TO_INSTALL_NAME[@]}-1))); do
        print -ni "-- Installing '${PACKAGES_TO_INSTALL_NAME[${i}]}'..."
        eval ${PACKAGES_TO_INSTALL_CMD[${i}]} >> ${PACKAGES_LOG} 2>&1
        
        if [ $? -eq 0 ]; then 
            print -s "SUCCESS"
        else 
            print -e "ERROR"
            MISSING_PACKAGES+=(${PACKAGES_TO_INSTALL_NAME[${i}]})
        fi
    done
fi

if [ ${#MISSING_PACKAGES[@]} -eq 0 ]; then
    print -s "All the packages are installed"
    echo
    exit 0
else 
    print -se "The following packages is missing: '${MISSING_PACKAGES[@]}'"
    print -si "Check '${PACKAGES_LOG}' for more informations"
    exit 5
fi