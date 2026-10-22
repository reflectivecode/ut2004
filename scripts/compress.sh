#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

if [ "${COMPRESS_DIR:-}" = "" ]; then
    echo "COMPRESS_DIR is not set, skipping compression"
    exit 0
fi

echo "Starting compression"

# find all files to compress
find "${UT2004_HOME}/.ut2004" -type f \( -name "*.ukx" -o -name "*.ka" -o -name "*.ut2" -o -name "*.uax" -o -name "*.usx" -o -name "*.u" -o -name "*.utx" \) | while read sourcepath; do
    filename=$(basename "${sourcepath}")          # get source filename without directory
    destination="${COMPRESS_DIR}/${filename}.uz2" # compressed file's path
    sourcedate=$(stat -c %Y "${sourcepath}")      # get source file's modification date

    # skip compression if compressed file already exists and timestamp matches the source
    if [ -e "${destination}" ]; then
        destinationdate=$(stat -c %Y "${destination}") # get compressed file's modification date
        if [ "${sourcedate}" -eq "${destinationdate}" ]; then
        echo "already compressed ${sourcepath}"
        continue
        fi
    fi

    "${UT2004_UCC}" compress "${sourcepath}"                                # compress the source file
    mv -f "${UT2004_HOME}/.ut2004/System${sourcepath}.uz2" "${destination}" # move compressed file to the destination
    chmod u=rw,go=r "${destination}"                                        # set read permission to compressed file
    touch -d "@${sourcedate}" "${destination}"                              # change modification date of compressed file to match the source
done

echo "Compression complete"
