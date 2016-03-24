#!/bin/bash

#set -x

if [ $# -lt 3 ]; then
  echo "Usage:"
  echo "  $0 GIT_WORKING_DIR_PATH MAJOR MINOR [out_version_header]"
  echo "if only 3 arguments are given, script prints current string version to stdout"
  exit 1
fi

GIT_WORKING_DIR_PATH="$1"
MAJOR=$2
MINOR=$3

# Windows workaround
WIN_GIT_BIN_PATH1="/C/Program Files/Git/bin"
if [ -e "$WIN_GIT_BIN_PATH1" ]; then
  PATH="$WIN_GIT_BIN_PATH1:$PATH"
else
  WIN_GIT_BIN_PATH2="/C/Program Files (x86)/Git/bin"
  if [ -e "$WIN_GIT_BIN_PATH2" ]; then
    PATH="$WIN_GIT_BIN_PATH2:$PATH"
  else
    MAC_GIT_BIN_PATH1=/usr/local/git/bin
    if [ -e "$MAC_GIT_BIN_PATH1" ]; then
      PATH="$MAC_GIT_BIN_PATH1:$PATH"
    fi
    MAC_GIT_BIN_PATH2=/opt/local/bin
    if [ -e "$MAC_GIT_BIN_PATH2" ]; then
      PATH="$MAC_GIT_BIN_PATH2:$PATH"
    fi
  fi
fi

BUILD_TIMESTAMP=`date -u +%y%m%d%H%M`
BUILD_TIMESTAMP_FULL=`date -u`

GIT_CMD="git --git-dir=$GIT_WORKING_DIR_PATH/.git --work-tree=$GIT_WORKING_DIR_PATH"

GIT_COMMIT=`cd $GIT_WORKING_DIR_PATH; $GIT_CMD log --oneline -1`
GIT_COMMIT_HASH=${GIT_COMMIT:0:7}

# check if git repo has local uncommitted modifications
STRING_MODIFICATIONS=""
GIT_STATUS_OUTPUT=`cd $GIT_WORKING_DIR_PATH; $GIT_CMD status -s -uno`
if [ -n "$GIT_STATUS_OUTPUT" ]; then
  STRING_MODIFICATIONS=".altered"
fi

STRING_VER="${MAJOR}.${MINOR}.${BUILD_TIMESTAMP}.${GIT_COMMIT_HASH}${STRING_MODIFICATIONS}"

if [ $# -eq 3 ]; then
  echo $STRING_VER
  exit 0
fi

# write out header
if [ $# -eq 4 ]; then
  OUT_FILE=$4

  echo "#pragma once" > $OUT_FILE
  echo "// This header is auto generated by script" >> $OUT_FILE
  echo "namespace Version" >> $OUT_FILE
  echo "{" >> $OUT_FILE
  echo "  static unsigned int const MAJOR = $MAJOR;" >> $OUT_FILE
  echo "  static unsigned int const MINOR = $MINOR;" >> $OUT_FILE
  echo "  static unsigned int const BUILD = $BUILD_TIMESTAMP;" >> $OUT_FILE
  echo "  static unsigned int const GIT_HASH = 0x$GIT_COMMIT_HASH;" >> $OUT_FILE 
  echo "  #define VERSION_STRING \"$STRING_VER\"" >> $OUT_FILE
  echo "  #define VERSION_DATE_STRING \"$BUILD_TIMESTAMP_FULL\"" >> $OUT_FILE
  echo "}" >> $OUT_FILE
  echo ""  >> $OUT_FILE
  exit 0
fi