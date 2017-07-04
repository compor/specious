#!/usr/bin/env bash

# initialize configuration vars

INPUT_LOOPID_WHITELIST_FILE=""
BUILD_TARGET=""

# set configuration vars

if [ -z "$1" ]; then
  echo "error: input file was not provided"

  exit 1
fi

if [ -z "$2" ]; then
  echo "error: build target was not provided"

  exit 1
fi

INPUT_LOOPID_WHITELIST_FILE=$1
BUILD_TARGET=$2

while true; do
  LAST_OUTPUT=`make $BUILD_TARGET 2>&1 | ag 'processing' | awk '{ print $4 }' | tail -f -n1 && echo ${PIPESTATUS[0]}`

  STATUS=`echo $LAST_OUTPUT | awk '{ print $2+0 }'`
  LAST_LOOPID=`echo $LAST_OUTPUT | awk '{ print $1 }'`
  
  echo "last loop id: ${LAST_LOOPID}"
  echo "status: ${STATUS}"

  if [ "${STATUS}" -eq 0 ]; then
    break
  fi

  awk -v faulty_loopid=$LAST_LOOPID '{ if($1 == faulty_loopid) print "#"$1; else print; }' $INPUT_LOOPID_WHITELIST_FILE > $INPUT_LOOPID_WHITELIST_FILE.new
  mv -f $INPUT_LOOPID_WHITELIST_FILE.new $INPUT_LOOPID_WHITELIST_FILE
done

exit $STATUS

