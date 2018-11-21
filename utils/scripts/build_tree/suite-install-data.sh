#!/usr/bin/env bash

#set -x

# internal vars

OUTS='/dev/stdout'
ERRS='/dev/stderr'

# initialize configuration vars

SCRIPT_HELP=0
SUITE_CONFIG_FILE=""
SUITE_SOURCE_DIR=""
SUITE_INSTALL_DIR=""
SUITE_DATA_TYPE=()

# parse and check cmd line options

CMDOPTS=":c:s:i:t:qh"

HELP_STRING=$(cat <<- END

Usage: ${0} OPTIONS

-c file       suite config file
-s dir        suite source directory
-i dir        suite install directory
-t string     data set type (use multiple times for more than one types)
-q            silent mode (no output)
-h            help

END
)

while getopts ${CMDOPTS} cmdopt; do
  case $cmdopt in
    c)
      SUITE_CONFIG_FILE=$OPTARG
      ;;
    s)
      SUITE_SOURCE_DIR=$OPTARG
      ;;
    i)
      SUITE_INSTALL_DIR=$OPTARG
      ;;
    t)
      SUITE_DATA_TYPE+=("${OPTARG}")
      ;;
    q)
      OUTS="/dev/null"
      ERRS="/dev/null"
      ;;
    h)
      SCRIPT_HELP=1
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


[[ $SCRIPT_HELP -ne 0 ]] && echo "$HELP_STRING" > $ERRS && exit 0


# print configuration vars

INFO_STR=$(cat <<- END
info: printing configuration vars
info: suite config file: ${SUITE_CONFIG_FILE}
info: suite source dir: ${SUITE_SOURCE_DIR}
info: suite install dir: ${SUITE_INSTALL_DIR}
info: benchmark suite data set type: ${SUITE_DATA_TYPE[@]}
END
)

echo "$INFO_STR" > $OUTS

if [[ -z $SUITE_CONFIG_FILE || ! -e $SUITE_CONFIG_FILE ]]; then
  echo "error: suite config file was not provided or does not exist" > $ERRS
  exit 1
fi

if [[ -z $SUITE_SOURCE_DIR || ! -e $SUITE_SOURCE_DIR ]]; then
  echo "error: suite source dir was not provided or does not exist" > $ERRS
  exit 1
fi

if [[ ${#SUITE_DATA_TYPE[@]} -lt 1 ]]; then
  SUITE_DATA_TYPE=("train" "test" "ref")
fi

if [[ ! -e $(which rsync) ]]; then
  echo "error: this script requires rsync" > $ERRS
  exit 1
fi

# operations

mkdir -p "${SUITE_INSTALL_DIR}"

# check if out dir location is given in relative form
[[ ${SUITE_INSTALL_DIR} == ${SUITE_INSTALL_DIR#/} ]] && SUITE_INSTALL_DIR="$(pwd)/${SUITE_INSTALL_DIR}"

readarray BENCHMARKS < ${SUITE_CONFIG_FILE}

for BMK in ${BENCHMARKS[@]}; do
  BMK=$(echo $BMK | tr -d [:space:])

  for TYPE in ${SUITE_DATA_TYPE[@]}; do
    BMK_SOURCE_DIR=${SUITE_SOURCE_DIR}/${BMK}/data/${TYPE}
    BMK_ALL_SOURCE_DIR=${SUITE_SOURCE_DIR}/${BMK}/data/all/input
    BMK_INSTALL_DIR=${SUITE_INSTALL_DIR}/${BMK}/data/${TYPE}

    mkdir -p ${BMK_INSTALL_DIR}

    rsync -krcq ${BMK_SOURCE_DIR}/ ${BMK_INSTALL_DIR}
    RC1=$?

    rsync -krcq ${BMK_ALL_SOURCE_DIR}/ ${BMK_INSTALL_DIR}/input
    RC2=$?

    MSG="installing ${BMK} ${TYPE} data"
    PRE_MSG="failure"
    [[ $RC1 -eq 0 && $RC2 -eq 0 ]] && PRE_MSG="success"
    echo "${PRE_MSG} ${MSG}" > $OUTS
  done
done

exit 0
