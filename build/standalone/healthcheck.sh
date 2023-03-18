#!/bin/sh

set -e

healthcheck() {
    # check that supervisor daemon is running
    if ! pgrep supervisord > /dev/null; then
        return 1
    fi
    # check that all managed process are running
    if ! supervisorctl status | grep RUNNING; then
        return 1
    fi
    return 0
}

healthcheck
exit $?
