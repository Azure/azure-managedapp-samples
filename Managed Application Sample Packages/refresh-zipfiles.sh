#!/bin/bash
script_name=`basename "$0"`
echo "Running $script_name"
# Setup error handling
tempfiles=( )
cleanup() {
  rm -f "${tempfiles[@]}"
}
trap cleanup 0

error() {
  local parent_lineno="$1"
  local message="$2"
  local code="${3:-1}"
  if [[ -n "$message" ]] ; then
    echo "Error on or near line ${parent_lineno}: ${message}; exiting with status ${code}"
  else
    echo "Error on or near line ${parent_lineno}; exiting with status ${code}"
  fi

  exit "${code}"
}
trap 'error ${LINENO}' ERR

refresh_file() {
    zipfile=$1
    dirname=$(dirname $zipfile)
    filename=$(basename $zipfile)
    pushd $dirname
    zip -f $filename
    popd
}

export -f refresh_file
find . -name "*.zip" -exec bash -c "refresh_file \"{}\"" \;