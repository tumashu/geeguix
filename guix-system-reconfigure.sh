#!/bin/bash

set -e

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

repeatcmd guix system reconfigure --substitute-urls=http://141.80.181.40 guix-system-helper.scm
