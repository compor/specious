#!/bin/bash
#set -e

BUILD_DIR="/home/vasich/Documents/workbench/repos/install-spec-polly/"
INPUT_TYPE="test"

# the integer set
BENCHMARKS=(400.perlbench 401.bzip2 403.gcc 429.mcf 445.gobmk 456.hmmer 458.sjeng 462.libquantum 464.h264ref 471.omnetpp 473.astar 483.xalancbmk)

for b in ${BENCHMARKS[@]}; do
  cd $BUILD_DIR/${b}
  SHORT_EXE=${b##*.} # cut off the numbers ###.short_exe

  # read the command file
  IFS=$'\n' read -d '' -r -a commands < $BUILD_DIR/commands/${b}.${INPUT_TYPE}.cmd

  for input in "${commands[@]}"; do
    if [[ ${input:0:1} != '#' ]]; then # allow us to comment out lines in the cmd files
      echo "~~~Running ${b}"
      pushd data/${INPUT_TYPE}/input/
      echo "  ${RUN} ${SHORT_EXE} ${input}"
      eval ${RUN} ../../../exe/${SHORT_EXE} ${input}
      popd
    fi
  done
done

echo ""
echo "Done!"

