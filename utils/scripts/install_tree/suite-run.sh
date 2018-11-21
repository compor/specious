#!/usr/bin/env bash

#set -x

# internal vars

OUTS='/dev/stdout'
ERRS='/dev/stderr'

# initialize configuration vars

SCRIPT_HELP=0
SCRIPT_JOBS=1
SCRIPT_CPU=0
SCRIPT_DRYRUN=0

SCRIPT_MAX_CPUS=$(nproc)

SUITE_CONFIG_FILE=""
SUITE_TARGET_DIR=""
SUITE_DATA_DIR=""
SUITE_DATA_TYPE=""


# parse and check cmd line options

CMDOPTS=":c:i:d:t:j:u:nqh"

HELP_STRING=$(cat <<- END
Usage: ${0} OPTIONS

-c file       benchmark suite config file
-i dir        benchmark suite target directory
-d dir        data set dir
-t string     data set type
-j N          perform N parallel jobs
-u N          run on CPU N and onwards parallel jobs
-q            silent mode (no output)
-n            dry run
-h            help
END
)

while getopts ${CMDOPTS} cmdopt; do
  case $cmdopt in
    c)
      SUITE_CONFIG_FILE=$OPTARG
      ;;
    i)
      SUITE_TARGET_DIR=$OPTARG
      ;;
    d)
      SUITE_DATA_DIR=$OPTARG
      ;;
    t)
      SUITE_DATA_TYPE=$OPTARG
      ;;
    j)
      SCRIPT_JOBS=$OPTARG
      ;;
    u)
      SCRIPT_CPU=$OPTARG
      ;;
    q)
      OUTS="/dev/null"
      ERRS="/dev/null"
      ;;
    h)
      SCRIPT_HELP=1
      ;;
    n)
      SCRIPT_DRYRUN=1
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

[[ $SCRIPT_DRYRUN -ne 0 ]] && echo "*** DRY RUN ***" > $ERRS

# print configuration vars

INFO_STR=$(cat <<- END

info: printing configuration vars
info: benchmark suite config file: ${SUITE_CONFIG_FILE}
info: benchmark suite target dir: ${SUITE_TARGET_DIR}
info: benchmark suite data set dir: ${SUITE_DATA_DIR}
info: benchmark suite data set type: ${SUITE_DATA_TYPE}
info: script jobs: ${SCRIPT_JOBS}
info: first job starting CPU: ${SCRIPT_CPU}

END
)

echo "$INFO_STR" > $OUTS

if [[ -z $SUITE_CONFIG_FILE ||  ! -e $SUITE_CONFIG_FILE ]]; then
  echo "error: benchmark suite config file was not provided or does not exist" > $ERRS
  exit 1
fi

if [[ -z $SUITE_TARGET_DIR || ! -e $SUITE_TARGET_DIR ]]; then
  echo "error: benchmark suite install dir was not provided or does not exist" > $ERRS
  exit 1
fi

if [[ ! -z $SUITE_DATA_DIR && ! -e $SUITE_DATA_DIR ]]; then
  echo "error: benchmark suite data dir does not exist" > $ERRS
  exit 1
fi

if [[ -z $SUITE_DATA_TYPE ]]; then
  echo "error: benchmark suite data set type was not provided" > $ERRS
  exit 1
fi

if [[ -z $SUITE_DATA_DIR ]]; then
  echo "warning: using SUITE_TARGET_DIR as SUITE_DATA_DIR" > $ERRS
  SUITE_DATA_DIR=$SUITE_TARGET_DIR
fi

if [[ $SCRIPT_CPU -ge $SCRIPT_MAX_CPUS ]]; then
  echo "warning: CPU number set to 0 becase provided value is greater than the available cores" > $ERRS
  SCRIPT_CPU=0
fi

if [[ $SCRIPT_JOBS -gt $SCRIPT_MAX_CPUS ]]; then
  echo "warning: number of jobs set to ${SCRIPT_MAX_CPUS} because provided value is greater than the available cores" > $ERRS
  SCRIPT_JOBS=${SCRIPT_MAX_CPUS}
fi


# operations

# check if out dir location is given in relative form
[[ "${SUITE_TARGET_DIR}" == "${SUITE_TARGET_DIR#/}" ]] && SUITE_TARGET_DIR="$(pwd)/${SUITE_TARGET_DIR}"
[[ "${SUITE_DATA_DIR}" == "${SUITE_DATA_DIR#/}" ]] && SUITE_DATA_DIR="$(pwd)/${SUITE_DATA_DIR}"

readarray BENCHMARKS < ${SUITE_CONFIG_FILE}

CPU_NUM=${SCRIPT_CPU}

[[ $SCRIPT_DRYRUN -eq 0 ]] && date +"%T" > started.txt

for BMK in ${BENCHMARKS[@]}; do
  BMK=$(echo $BMK | tr -d [:space:])
  SUITE_EXE=${BMK##*.}

  # read command args file
  SUITE_ARGS_FILE=${SUITE_DATA_DIR}/invocations/${SUITE_DATA_TYPE}/${BMK}.${SUITE_DATA_TYPE}.cmd
  IFS=$'\n' read -d '' -r -a SUITE_ARGS < ${SUITE_ARGS_FILE}

  echo "running ${BMK} on CPU ${CPU_NUM}" > $OUTS

  # this cur working directory change is essentially bound to the way each
  # benchmark is invoked by the corresponding arguments file
  # the downside is that any output file is created in the input date location
  pushd ${SUITE_DATA_DIR}/${BMK}/data/${SUITE_DATA_TYPE}/input/ > $OUTS

  OUTPUT_FILE_COUNT=0

  echo "${SUITE_EXE} ${SUITE_DATA_TYPE}" > $OUTS

  for SUITE_ARG in "${SUITE_ARGS[@]}"; do
    echo "with arguments: ${SUITE_ARG}" > $OUTS

    if [[ $SCRIPT_DRYRUN -eq 0 ]]; then
      if [[ $SCRIPT_JOBS -gt 1 ]]; then
        sem --no-notice -j ${SCRIPT_JOBS} "taskset -c ${CPU_NUM} ${SUITE_TARGET_DIR}/${BMK}/exe/${SUITE_EXE} ${SUITE_ARG}"
      else
        taskset -c ${CPU_NUM} ${SUITE_TARGET_DIR}/${BMK}/exe/${SUITE_EXE} ${SUITE_ARG}
        #taskset -c ${CPU_NUM} perf record -o perf${OUTPUT_FILE_COUNT}.data -g -- ${SUITE_TARGET_DIR}/${BMK}/exe/${SUITE_EXE} ${SUITE_ARG}
      fi
    fi

    [[ $SCRIPT_JOBS -gt 1 ]] && let CPU_NUM=(CPU_NUM+1)%SCRIPT_MAX_CPUS
    let OUTPUT_FILE_COUNT++
  done

  popd > $OUTS
done

[[ $SCRIPT_DRYRUN -eq 0 ]] && [[ $SCRIPT_JOBS -gt 1 ]] && sem --wait

[[ $SCRIPT_DRYRUN -eq 0 ]] && date +"%T" > finished.txt

exit 0

