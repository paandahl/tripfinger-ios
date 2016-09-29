# Sets the minimum version of CMake required to build the native
# library. You should either keep the default value or only pass a
# value of 3.4.0 or lower.

cmake_minimum_required(VERSION 3.4.1)

# Creates and names a library, sets it as either STATIC
# or SHARED, and provides the relative paths to its source code.
# You can define multiple libraries, and CMake builds it for you.
# Gradle automatically packages shared libraries with your APK.

add_library( # Sets the name of the library.
             native-lib

             # Sets the library as a shared library.
             SHARED

             # Provides a relative path to your source file(s).
             # Associated headers in the same location as their source
             # file are automatically included.
             src/main/cpp/native-lib.cpp
             src/main/cpp/MapFragment.cpp
             src/main/cpp/core/jni_helper.cpp
             src/main/cpp/core/logging.cpp
             src/main/cpp/core/ScopedLocalRef.hpp
             src/main/cpp/maps/Framework.cpp
             src/main/cpp/maps/UserMarkHelper.cpp
             src/main/cpp/opengl/android_gl_utils.cpp
             src/main/cpp/opengl/androidoglcontext.cpp
             src/main/cpp/opengl/androidoglcontextfactory.cpp
             src/main/cpp/platform/HttpThread.cpp
             src/main/cpp/platform/Language.cpp
             src/main/cpp/platform/Platform.cpp
             src/main/cpp/platform/PThreadImpl.cpp)

# Searches for a specified prebuilt library and stores the path as a
# variable. Because system libraries are included in the search path by
# default, you only need to specify the name of the public NDK library
# you want to add. CMake verifies that the library exists before
# completing its build.

#message(FATAL_ERROR "Looking up libs for arch: " ${ANDROID_ABI} )

include_directories(../../)
include_directories(../../3party/boost)
include_directories(../../3party/protobuf/src)
include_directories(../../3party/glm)

find_library(log-lib log)
find_library(z-lib z)
find_library(android-lib android)
find_library(egl-lib EGL)
find_library(gles2-lib GLESv2)
find_library(stdcpp-lib stdc++)

find_library(MWM_PLATFORM       platform        PATHS ../../../omim-android-debug-${ANDROID_ABI}/out/debug CMAKE_FIND_ROOT_PATH_BOTH)
find_library(MWM_STATS_CLIENT   stats_client    PATHS ../../../omim-android-debug-${ANDROID_ABI}/out/debug CMAKE_FIND_ROOT_PATH_BOTH)
find_library(MWM_MAP            map             PATHS ../../../omim-android-debug-${ANDROID_ABI}/out/debug CMAKE_FIND_ROOT_PATH_BOTH)
find_library(MWM_SEARCH         search          PATHS ../../../omim-android-debug-${ANDROID_ABI}/out/debug CMAKE_FIND_ROOT_PATH_BOTH)
find_library(MWM_DRAPE_FRONTEND drape_frontend  PATHS ../../../omim-android-debug-${ANDROID_ABI}/out/debug CMAKE_FIND_ROOT_PATH_BOTH)
find_library(MWM_DRAPE          drape           PATHS ../../../omim-android-debug-${ANDROID_ABI}/out/debug CMAKE_FIND_ROOT_PATH_BOTH)
find_library(MWM_STORAGE        storage         PATHS ../../../omim-android-debug-${ANDROID_ABI}/out/debug CMAKE_FIND_ROOT_PATH_BOTH)
find_library(MWM_ROUTING        routing         PATHS ../../../omim-android-debug-${ANDROID_ABI}/out/debug CMAKE_FIND_ROOT_PATH_BOTH)
find_library(MWM_INDEXER        indexer         PATHS ../../../omim-android-debug-${ANDROID_ABI}/out/debug CMAKE_FIND_ROOT_PATH_BOTH)
find_library(MWM_GEOMETRY       geometry        PATHS ../../../omim-android-debug-${ANDROID_ABI}/out/debug CMAKE_FIND_ROOT_PATH_BOTH)
find_library(MWM_CODING         coding          PATHS ../../../omim-android-debug-${ANDROID_ABI}/out/debug CMAKE_FIND_ROOT_PATH_BOTH)
find_library(MWM_BASE           base            PATHS ../../../omim-android-debug-${ANDROID_ABI}/out/debug CMAKE_FIND_ROOT_PATH_BOTH)
find_library(MWM_FREETYPE       freetype        PATHS ../../../omim-android-debug-${ANDROID_ABI}/out/debug CMAKE_FIND_ROOT_PATH_BOTH)
find_library(MWM_FRIBIDI        fribidi         PATHS ../../../omim-android-debug-${ANDROID_ABI}/out/debug CMAKE_FIND_ROOT_PATH_BOTH)
find_library(MWM_MINIZIP        minizip         PATHS ../../../omim-android-debug-${ANDROID_ABI}/out/debug CMAKE_FIND_ROOT_PATH_BOTH)
find_library(MWM_JANSSON        jansson         PATHS ../../../omim-android-debug-${ANDROID_ABI}/out/debug CMAKE_FIND_ROOT_PATH_BOTH)
find_library(MWM_TOMCRYPT       tomcrypt        PATHS ../../../omim-android-debug-${ANDROID_ABI}/out/debug CMAKE_FIND_ROOT_PATH_BOTH)
find_library(MWM_EXPAT          expat           PATHS ../../../omim-android-debug-${ANDROID_ABI}/out/debug CMAKE_FIND_ROOT_PATH_BOTH)
find_library(MWM_PROTOBUF       protobuf        PATHS ../../../omim-android-debug-${ANDROID_ABI}/out/debug NO_DEFAULT_PATH CMAKE_FIND_ROOT_PATH_BOTH)
find_library(MWM_OSRM           osrm            PATHS ../../../omim-android-debug-${ANDROID_ABI}/out/debug CMAKE_FIND_ROOT_PATH_BOTH)
find_library(MWM_SUCCINCT       succinct        PATHS ../../../omim-android-debug-${ANDROID_ABI}/out/debug CMAKE_FIND_ROOT_PATH_BOTH)
find_library(MWM_OPENING_HOURS  opening_hours   PATHS ../../../omim-android-debug-${ANDROID_ABI}/out/debug CMAKE_FIND_ROOT_PATH_BOTH)
find_library(MWM_PUGIXML        pugixml         PATHS ../../../omim-android-debug-${ANDROID_ABI}/out/debug CMAKE_FIND_ROOT_PATH_BOTH)
find_library(MWM_OAUTHCPP       oauthcpp        PATHS ../../../omim-android-debug-${ANDROID_ABI}/out/debug CMAKE_FIND_ROOT_PATH_BOTH)
find_library(MWM_EDITOR         editor          PATHS ../../../omim-android-debug-${ANDROID_ABI}/out/debug CMAKE_FIND_ROOT_PATH_BOTH)

# Specifies libraries CMake should link to your target library. You
# can link multiple libraries, such as libraries you define in the
# build script, prebuilt third-party libraries, or system libraries.


target_link_libraries(native-lib

                       ${log-lib}
                       ${z-lib}
                       ${android-lib}
                       ${egl-lib}
                       ${gles2-lib}
                       ${stdcpp-lib}

                       ${MWM_MAP}
                       ${MWM_SEARCH}
                       ${MWM_DRAPE_FRONTEND}
                       ${MWM_DRAPE}
                       ${MWM_STORAGE}
                       ${MWM_ROUTING}
                       ${MWM_INDEXER}
                       ${MWM_PLATFORM}
                       ${MWM_GEOMETRY}
                       ${MWM_CODING}
                       ${MWM_BASE}
                       ${MWM_FREETYPE}
                       ${MWM_FRIBIDI}
                       ${MWM_MINIZIP}
                       ${MWM_JANSSON}
                       ${MWM_TOMCRYPT}
                       ${MWM_EXPAT}
                       ${MWM_PROTOBUF}
                       ${MWM_OSRM}
                       ${MWM_SUCCINCT}
                       ${MWM_OPENING_HOURS}
                       ${MWM_PUGIXML}
                       ${MWM_EDITOR}
                       ${MWM_OAUTHCPP}
                       ${MWM_STATS_CLIENT}
                       )