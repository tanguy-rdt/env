#!/bin/bash

FILE_NAME=$(readlink -f "$0")
SCRIPTS_DIR=$(dirname "${FILE_NAME}")
ROOT_DIR=${SCRIPTS_DIR}/..
TOML_FILE=${1}
JOB_LOG=${2}

source ${SCRIPTS_DIR}/utils.sh

if [ ! -f "${JOB_LOG}" ]; then
    echo "" > ${JOB_LOG}
fi

if [ ! -f "${TOML_FILE}" ]; then
    print -se "${TOML_FILE} not found"
    exit 1
fi

JOB_NAME=()
JOB_RUN_CMD=()
JOB_CHECK_CMD=()
JOB_EXPECTED_RES=()
JOB_HOVERED=0
while IFS= read -r LINE; do
    if [[ "${LINE}" =~ \[\[job\]\] ]]; then
        JOB_HOVERED=$((JOB_HOVERED + 1))
        for i in {0..3}; do
            read -r PACKAGE_INFO_LINE

            if [[ $PACKAGE_INFO_LINE =~ job_name\ =\ \'(.*)\' ]]; then
                JOB_NAME+=("${BASH_REMATCH[1]}")
            elif [[ $PACKAGE_INFO_LINE =~ run_command\ =\ \'(.*)\' ]]; then
                JOB_RUN_CMD+=("${BASH_REMATCH[1]}")
            elif [[ $PACKAGE_INFO_LINE =~ check_command\ =\ \'(.*)\' ]]; then
                JOB_CHECK_CMD+=("${BASH_REMATCH[1]}")
            elif [[ $PACKAGE_INFO_LINE =~ expected_result\ =\ ([0-9]+) ]]; then
                JOB_EXPECTED_RES+=("${BASH_REMATCH[1]}")
            fi
        done
    fi
done < "$TOML_FILE"

if [[ ${#JOB_NAME[@]} -ne ${#JOB_RUN_CMD[@]} || \
      ${#JOB_NAME[@]} -ne ${#JOB_CHECK_CMD[@]} || \
      ${#JOB_NAME[@]} -ne ${#JOB_EXPECTED_RES[@]} ]]; then
    print -se "Some information is missing from the job declaration"
    print -e "\t Number of 'job_name' found ${#JOB_NAME[@]}"
    print -e "\t Number of 'run_command' found ${#JOB_RUN_CMD[@]}"
    print -e "\t Number of 'check_command' found ${#JOB_CHECK_CMD[@]}"
    print -e "\t Number of 'expected_result' found ${#JOB_EXPECTED_RES[@]}"

    exit 3
fi

JOB_TO_RUN_NAME=()
JOB_TO_RUN_CMD=()
for i in $(seq 0 $((${#JOB_CHECK_CMD[@]}-1))); do
    eval ${JOB_CHECK_CMD[${i}]}  > /dev/null 2>&1

    if [ $? -ne ${JOB_EXPECTED_RES[${i}]} ]; then
        JOB_TO_RUN_NAME+=("${JOB_NAME[${i}]}")
        JOB_TO_RUN_CMD+=("${JOB_RUN_CMD[${i}]}")
    fi
done

if [ -n "${JOB_TO_RUN_NAME}" ]; then 
    print -sw "The job '${JOB_TO_RUN_NAME[@]}' need to be executed:"
    for i in $(seq 0 $((${#JOB_TO_RUN_NAME[@]}-1))); do
        print -w "\t-- ${JOB_TO_RUN_NAME[${i}]}"
    done
    echo
    print -nw "Are you agree ? [y/n]:"
    
    read -n1 yn
    yn=${yn:-y}
    echo

    yn=${yn,,}
    if [[ "$yn" != "y" && "$yn" != "yes" ]]; then
        exit 100
    fi

    root_privilege
    
    echo
    MISSING_JOB=()
    for i in $(seq 0 $((${#JOB_TO_RUN_NAME[@]}-1))); do
        print -ni "-- ${JOB_TO_RUN_NAME[${i}]}..."
        eval ${JOB_TO_RUN_CMD[${i}]} >> ${JOB_LOG} 2>&1
        
        if [ $? -eq 0 ]; then 
            print -s "SUCCESS"
        else 
            print -e "ERROR"
            MISSING_JOB+=(${JOB_TO_RUN_NAME[${i}]})
        fi
    done
fi

if [ ${#MISSING_JOB[@]} -eq 0 ]; then
    exit 0
else 
    print -se "An error has occurred during execution of the following job: '${MISSING_JOB[@]}'"
    print -si "Check '${JOB_LOG}' for more informations"
    exit ${#MISSING_JOB[@]}
fi