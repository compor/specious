#!/usr/bin/env bash

# internal vars

OUTS='/dev/stdout'
ERRS='/dev/stderr'


# initialize configuration vars

SHOW_HELP=0
BMK_CONFIG_FILE=""
BMK_SOURCE_DIR=""
OUTPUT_DIRNAME="$(pwd)"
OUTPUT_SUFFIX=".project_files.txt"


# parse and check cmd line options

CMDOPTS=":c:s:o:d:qh"

HELP_STRING="\
Usage: ${0} OPTIONS

-c file    benchmark config file
-s dir     benchmark source directory
-o string  output file name suffix
-d dir     output dir name
-q         silent mode (no output)
-h         help
"

while getopts $CMDOPTS cmdopt; do
  case $cmdopt in
    c)
      BMK_CONFIG_FILE=$OPTARG
      ;;
    s)
      BMK_SOURCE_DIR=$OPTARG
      ;;
    o)
      OUTPUT_SUFFIX=$OPTARG
      ;;
    d)
      OUTPUT_DIRNAME=$OPTARG
      ;;
    h)
      SHOW_HELP=1
      ;;
    q)
      OUTS="/dev/null"
      ERRS="/dev/null"
      ;;
    \?)
      echo "error: invalid option: -$OPTARG" > $ERRS
      exit 1
      ;;
    :)
      echo "error: option -$OPTARG requires an argument" > $ERRS
      exit 1
      ;;
  esac
done


if [ "$SHOW_HELP" -ne 0 ]; then
  echo "$HELP_STRING" > $ERRS

  exit 0
fi

if [ -z ${BMK_CONFIG_FILE:+x} -o ! -e ${BMK_CONFIG_FILE} ]; then
  echo "error: benchmark config file was not provided or does not exist" > $ERRS

  exit 1
fi

if [ -z ${BMK_SOURCE_DIR:+x} -o ! -e ${BMK_SOURCE_DIR} ]; then
  echo "error: benchmark source dir was not provided or does not exist" > $ERRS

  exit 1
fi


# print configuration vars

INFO_STR="\
info: printing configuration vars
info: benchmark config file: ${BMK_CONFIG_FILE}
info: benchmark source dir: ${BMK_SOURCE_DIR}
info: output dir: ${OUTPUT_DIRNAME}
info: output file name suffix: ${OUTPUT_SUFFIX}
"

echo "$INFO_STR" > $OUTS


# operations

if [ ! -e "$OUTPUT_DIRNAME" ]; then
  mkdir -p "${OUTPUT_DIRNAME}"

  if [ $? -ne 0 ]; then
    echo "error: output dir could not be created" > $ERRS

    exit 1
  fi
fi

# check if out dir location is given in relative form
if [ "${OUTPUT_DIRNAME}" == "${OUTPUT_DIRNAME#/}" ]; then
  OUTPUT_DIRNAME=$(pwd)/${OUTPUT_DIRNAME}
fi

readarray BENCHMARKS < ${BMK_CONFIG_FILE}

for BMK in ${BENCHMARKS[@]}; do
  OUTFILENAME=${BMK}${OUTPUT_SUFFIX}

  pushd ${BMK_SOURCE_DIR}/${BMK}/src/ > $OUTS

  find . \
       -iname '*.h' \
    -o -iname '*.hpp' \
    -o -iname '*.hxx' \
    -o -iname '*.c' \
    -o -iname '*.cpp' \
    -o -iname '*.cxx' > ${OUTPUT_DIRNAME}/${OUTFILENAME}
  
  popd > $OUTS
done


exit 0

