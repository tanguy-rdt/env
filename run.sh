#!/bin/bash

FILE_NAME=$(readlink -f "$0")
WORKDIR=$(dirname "${FILE_NAME}")
LOG_DIR=${WORKDIR}/log
CONFIG_DIR=""

source ${WORKDIR}/scripts/utils.sh

usage() {
cat << EOF

Usage: $0 [OPTION]...

OPTIONS:
  -d, --debian     setup env for debian
  -u, --ubuntu     setup env for ubuntu
  -clean          clean project

  -h, --help      Show this help

EOF
}

debian() {
    print -i "Start the environment configurator for debian"
    echo

    CONFIG_DIR=${WORKDIR}/config/debian
    run
}

ubuntu() {
    print -se "The environment configurator for ubuntu is not yet supported"
}

run() {
    chmod +x ${WORKDIR}/scripts/dependencies.sh
    ${WORKDIR}/scripts/dependencies.sh ${CONFIG_DIR}
    if [ ! $? -eq 0 ]; then
        exit $?
    fi

    chmod +x ${WORKDIR}/scripts/build.sh
    ${WORKDIR}/scripts/build.sh
    if [ ! $? -eq 0 ]; then
        exit $?
    fi

    chmod +x ${WORKDIR}/scripts/run.sh
    ${WORKDIR}/scripts/run.sh ${CONFIG_DIR}
    if [ ! $? -eq 0 ]; then
        exit $?
    fi
}

clean() {
    rm -rf ${WORKDIR}/build
    rm -rf ${WORKDIR}/dist
    rm -rf ${WORKDIR}/log
}


if [ ! -d ${LOG_DIR} ]; then 
    mkdir -p ${LOG_DIR}
fi

case "${1}" in
    -d|--debian)
        debian
        ;;
    -u|--ubuntu)
        ubuntu
        ;;
    -clean)
        clean
        ;;
    -h|--help)
        usage
        exit 0
        ;;
    *)
        print -se "Unrecognized option '$1'."
        usage
        exit 1
        ;;
esac


