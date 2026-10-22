#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

if [ "${UT2004_UCC:-}" = "" ]; then
    if [ "${UT2004_ARCH}" = "32" ]; then
        export UT2004_UCC=${UT2004_UCC32}
    elif [ "${UT2004_ARCH}" = "64" ]; then
        export UT2004_UCC=${UT2004_UCC64}
    else
        echo "UT2004_ARCH must be set to either '32' or '64', but was '${UT2004_ARCH}'"
        exit 1
    fi
fi

download.sh

config.sh

compress.sh

echo "Setting permissions on ${UT2004_HOME}/.ut2004"
chown -R ut2004:ut2004 "${UT2004_HOME}/.ut2004"
chmod -R a=,u=rwX "${UT2004_HOME}/.ut2004"

echo "Starting unreal server"
exec "${UT2004_UCC}" server "${UT2004_CMD}"
