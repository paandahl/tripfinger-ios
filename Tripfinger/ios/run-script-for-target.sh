#!/bin/bash
# This script builds C++ core libs and inserts some private variables.
# Should be run from Run Script phase in target's settings.

echo "Running C++ MWM build pipeline with build profile:"
echo $MWM_BUILD_PROFILE
LOWERED_CONFIG=`echo $MWM_BUILD_PROFILE | tr [A-Z] [a-z]`
CONF="simulator"
DRAPE_CONF="old_renderer"
if [[ "$LOWERED_CONFIG" == *production* || "$LOWERED_CONFIG" == *adhoc* ]]; then
  CONF="production"
elif [[ "$LOWERED_CONFIG" == *debug* ]]; then
  if [[ "$LOWERED_CONFIG" == *simulator* ]]; then
    CONF="simulator-debug"
  else
    CONF="debug"
  fi
elif [[ "$LOWERED_CONFIG" == *release* ]]; then
  if [[ "$LOWERED_CONFIG" == *simulator* ]]; then
    CONF="simulator-release"
  else
    CONF="release"
  fi
fi
echo "Build profile was translated into internal configuration:"
echo $CONF

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
bash "$SRCROOT/../../tools/autobuild/ios.sh" $CONF $DRAPE_CONF
