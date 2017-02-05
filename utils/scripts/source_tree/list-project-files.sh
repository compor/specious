#!/usr/bin/env bash

# initialize configuration vars

SHOW_HELP=0
BMK_SOURCE_DIR=""
OUTPUT_FILENAME="project_files.txt"


# parse and check cmd line options

CMDOPTS=":f:s:o:h"

HELP_STRING="Usage: ${0} OPTIONS

-f file    benchmark config file
-s dir     benchmark source directory
-o file    output file name
-h         help
"

while getopts $CMDOPTS cmdopt; do
  case $cmdopt in
    f)
      BMK_CONFIG_FILE=$OPTARG
      ;;
    s)
      BMK_SOURCE_DIR=$OPTARG
      ;;
    o)
      OUTPUT_FILENAME=$OPTARG
      ;;
    h)
      SHOW_HELP=1
      ;;
    \?)
      echo "error: invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "error: option -$OPTARG requires an argument" >&2
      exit 1
      ;;
  esac
done


if [ "$SHOW_HELP" -ne 0 ]; then
  echo "$HELP_STRING" >&2

  exit 0
fi

if [ -z "$BMK_CONFIG_FILE" -a ! -e "$BMK_CONFIG_FILE" ]; then
  echo "error: benchmark config file was not provided or does not exist" >&2

  exit 1
fi

if [ -z "$BMK_SOURCE_DIR" -a ! -e "$BMK_SOURCE_DIR" ]; then
  echo "error: benchmark source dir was not provided or does not exist" >&2

  exit 1
fi


# print configuration vars

echo "info: printing configuration vars"
echo "info: benchmark config file: ${BMK_CONFIG_FILE}"
echo "info: benchmark source dir: ${BMK_SOURCE_DIR}"
echo "info: output file name: ${OUTPUT_FILENAME}"
echo ""


# operations

readarray BENCHMARKS < ${BMK_CONFIG_FILE}

for BMK in ${BENCHMARKS[@]}; do
  pushd $BMK_SOURCE_DIR/${BMK}/src/
  find . -name '*.h' \
    -o -name '*.hpp' \
    -o -name '*.hxx' \
    -o -name '*.C' \
    -o -name '*.c' \
    -o -name '*.cpp' \
    -o -name '*.cxx' > ../${OUTPUT_FILENAME}
  popd
done


exit 0

