#!/usr/bin/env bash

# internal vars

OUTS='/dev/stdout'
ERRS='/dev/stderr'


# initialize configuration vars

SHOW_HELP=0
BMK_CONFIG_FILE=""
BMK_SOURCE_DIR=""
BMK_TARGET_DIR=""
BMK_SUBDIRS=""


# parse and check cmd line options

CMDOPTS=":c:s:t:l:qh"

CMD_ARGS_DEFAULT=("-l src")

SCRIPT_ARGS=("${@}" "${CMD_ARGS_DEFAULT[@]}")

HELP_STRING="Usage: ${0} OPTIONS

-c file    benchmark config file
-s dir     benchmark source directory
-t dir     benchmark target directory
-l subdir  benchmark subdir (use multiple times for more than one subdirs)
           default value: src
-q         silent mode (no output)
-h         help
"

while getopts ${CMDOPTS} cmdopt "${SCRIPT_ARGS[@]}"; do
  case $cmdopt in
    c)
      BMK_CONFIG_FILE=$OPTARG
      ;;
    s)
      BMK_SOURCE_DIR=$OPTARG
      ;;
    t)
      BMK_TARGET_DIR=$OPTARG
      ;;
    l)
      BMK_SUBDIRS=("${BMK_SUBDIRS[@]}" "${OPTARG}")
      ;;
    q)
      OUTS="/dev/null"
      ERRS="/dev/null"
      ;;
    h)
      SHOW_HELP=1
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

if [ -z "$BMK_CONFIG_FILE" -o ! -e "$BMK_CONFIG_FILE" ]; then
  echo "error: benchmark config file was not provided or does not exist" > $ERRS

  exit 1
fi

if [ -z "$BMK_SOURCE_DIR" -o ! -e "$BMK_SOURCE_DIR" ]; then
  echo "error: benchmark source dir was not provided or does not exist" > $ERRS

  exit 1
fi

if [ -z "$BMK_TARGET_DIR" -o ! -e "$BMK_TARGET_DIR" ]; then
  echo "error: benchmark target dir was not provided or does not exist" > $ERRS

  exit 1
fi


# print configuration vars

INFO_STR="\
info: printing configuration vars
info: benchmark config file: ${BMK_CONFIG_FILE}
info: benchmark source dir: ${BMK_SOURCE_DIR}
info: benchmark target dir: ${BMK_TARGET_DIR}
info: benchmark subdirs: 
"

echo "$INFO_STR" > $OUTS
for BMK_SUBDIR in ${BMK_SUBDIRS[@]}; do 
  echo -n "${BMK_SUBDIR} " > $OUTS
done


# operations

# check if out dir location is given in relative form
if [ "${BMK_SOURCE_DIR}" == "${BMK_SOURCE_DIR#/}" ]; then 
  BMK_SOURCE_DIR="$(pwd)/${BMK_SOURCE_DIR}"
fi

readarray BENCHMARKS < ${BMK_CONFIG_FILE}

for BMK in "${BENCHMARKS[@]}"; do
  # trim whitespace
  BMK=$(echo $BMK | xargs)

  for BMK_SUBDIR in "${BMK_SUBDIRS[@]}"; do
    # trim whitespace
    BMK_SUBDIR=$(echo $BMK_SUBDIR | xargs)

    [ -z ${BMK_SUBDIR} ] && continue

    BMK_SUBDIR="${BMK_SOURCE_DIR}/${BMK}/${BMK_SUBDIR}"
    echo "${BMK_SUBDIR}" > $OUTS

    [ ! -d ${BMK_SUBDIR} ] && continue

    pushd "${BMK_TARGET_DIR}/${BMK}" > $OUTS

    ln -sf ${BMK_SUBDIR}

    popd > $OUTS
  done
done


exit $?

