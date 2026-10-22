#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

echo "Setting permissions on ${UT2004_HOME}/.ut2004"
mkdir -p "${UT2004_HOME}/.ut2004/System"
chown -R ut2004:ut2004 "${UT2004_HOME}/.ut2004"
chmod -R a=,u=rwX "${UT2004_HOME}/.ut2004"

if [ "${COMPRESS_DIR:-}" != "" ]; then
    echo "Setting permissions on ${COMPRESS_DIR}"
    mkdir -p "${COMPRESS_DIR}"
    chown -R ut2004:ut2004 "${COMPRESS_DIR}"
    chmod -R a=,u=rwX,go=rX "${COMPRESS_DIR}"
fi

echo "Running run-user.sh as ut2004 user"
gosu ut2004 run-user.sh
