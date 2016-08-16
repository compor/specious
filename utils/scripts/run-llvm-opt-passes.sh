#!/bin/bash

#

OPT_LIB=(
  ""
)

OPT_OPTION=(
  "-mem2reg -simplifycfg -loop-simplify -mergefunc"
)

OPT_SUFFIX=(
  "-std"
)


# initialize configuration vars

BC_INPUT_FILE=""

# set configuration vars

if [ -z "$1" ]; then 
  echo "error: LLVM bitcode input file was not provided" 

  exit 1
fi

BC_INPUT_FILE=$1


# print configuration vars

echo "info: printing configuation vars"
echo "info: LLVM bitcode input file: ${BC_INPUT_FILE}"
echo ""

#


OUT_DIR=$(dirname ${BC_INPUT_FILE})
INPUT_FULL_FNAME=$(basename ${BC_INPUT_FILE})
INPUT_FNAME=${INPUT_FULL_FNAME%.*}
INPUT_FILE_EXT=${INPUT_FULL_FNAME##*.}


OPT_LEN=${#OPT_LIB[@]}
OPT_IN=${INPUT_FULL_FNAME}
OPT_OUT_FNAME=${INPUT_FNAME}
OPT_OUT_FULL_FNAME=${OPT_IN} # in case the loop iterates 0 times

for (( i=0; i < ${OPT_LEN}; i++ ));
do
  OPT_OUT_FNAME=${OPT_OUT_FNAME}${OPT_SUFFIX[$i]}
  OPT_OUT_FULL_FNAME=${OUT_DIR}/${OPT_OUT_FNAME}"."${INPUT_FILE_EXT}
  opt ${OPT_LIB[$i]} ${OPT_OPTION[$i]} ${OPT_IN} -o ${OPT_OUT_FULL_FNAME}
  OPT_IN=${OPT_OUT_FULL_FNAME}
done


clang -o ${OPT_OUT_FNAME} \
  -lc++ -lc++abi -L$PROFLIB -lcommprofilerrt \
  -Wl,-rpath=$(llvm-config --libdir):$PROFLIB \
  ${OPT_OUT_FULL_FNAME}


exit $?

