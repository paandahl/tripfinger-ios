#!/bin/bash
# This script builds C++ core libs and inserts some private variables.
# Should be run from Run Script phase in target's settings.

echo "Running C++ MWM build pipeline with build profile:"
echo $MWM_BUILD_PROFILE
LOWERED_CONFIG=`echo $MWM_BUILD_PROFILE | tr [A-Z] [a-z]`
DRAPE_CONF="old_renderer"

if [[ "$LOWERED_CONFIG" == *drape* ]]; then
  echo "Drape renderer building"
  DRAPE_CONF="drape"
fi

# Respect "Build for active arch only" project setting.
if [[ "$ONLY_ACTIVE_ARCH" == YES ]]; then
  if [[ ! -z $CURRENT_ARCH ]]; then
    VALID_ARCHS="$CURRENT_ARCH"
  fi
fi

echo "Building $CONF configuration"
bash "$SRCROOT/../../tools/autobuild/ios.sh" $MWM_BUILD_PROFILE $DRAPE_CONF
