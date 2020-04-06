#!/bin/bash

set -e

GUIX_GIT_URL="https://github.com/guix-mirror/guix"
GUIX_SUBSTITUTE_URLS="http://141.80.181.40"
GUIX_MAX_SILENT_TIME="120"
GUIX_SYSTEM_CONFIG_FILE="guix-system-helper.scm"

function repeatcmd() {
    set +e
    count=0
    while [ 0 -eq 0 ]
    do
        echo "Run $@ ..."
        $@
        if [ $? -eq 0 ]; then
            break;
        else
            count=$[${count}+1]
            if [ ${count} -eq 100 ]; then
                echo 'Timeout and exit.'
                exit 1;
            fi
            echo "Retry ..."
            sleep 3
        fi
    done
    set -e
}

function guix_pull() {
    repeatcmd guix pull \
              --max-silent-time=${GUIX_MAX_SILENT_TIME} \
              --url=${GUIX_GIT_URL} \
              --substitute-urls=${GUIX_GIT_URL}
}

function guix_system_reconfigure() {
    repeatcmd sudo guix system reconfigure \
              --max-silent-time=${GUIX_MAX_SILENT_TIME} \
              --substitute-urls=${GUIX_GIT_URL} \
              ${GUIX_SYSTEM_CONFIG_FILE}
}

function display_usage() {
    cat <<HELP
用法: bash ./guix-system-helper.sh [选项]
选项:
    -p, --pull            guix pull
    -r, --reconfigure     guix system reconfigure
HELP
}

function main() {
    while true
    do
        case "$1" in
            -h|--help)
                display_usage;
                exit 0
                ;;
            -p|--pull)
                guix_pull;
                exit 0
                ;;
            -r|--reconfigure)
                guix_system_reconfigure;
                exit 0
                ;;
            --)
                shift
                break
                ;;
            *)
                echo "错误的选项！"
                exit 1
        esac
    done
    guix_pull;
}

# 选项
ARGS=$(getopt -o hpr --long help,pull,reconfigure -n "$0" -- "$@")


if [[ $? != 0 ]]; then
    echo "错误的选项！"
    display_usage
    exit 1
fi

eval set -- "${ARGS}"

main "$@"
