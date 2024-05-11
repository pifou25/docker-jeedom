#!/bin/bash

set -e

healthcheck() {
    # check that supervisor daemon is running
    if ! pgrep supervisord > /dev/null; then
        return 1
    fi
    # check that all managed process are running
    RUNNING=$(supervisorctl status | grep RUNNING | wc -l)
    if [[ $RUNNING -ne 5 ]] ; then
        return 1
    fi
    return 0
}

healthcheck
exit $?
