#!/usr/bin/env bash

set -ex

export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=2

read -r -d '' CTEST_CACHE << EOM || true
CMAKE_PREFIX_PATH:PATH=${COREBINARYDIRECTORY}
SWIG_EXECUTABLE:FILEPATH=${COREBINARYDIRECTORY}\swigwin\swig.exe
BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=ON
SimpleITK_BUILD_DISTRIBUTE:BOOL=ON
CSHARP_PLATFORM:STRING=${PYTHON_ARCH}
EOM


export CTEST_CACHE
export CTEST_BINARY_DIRECTORY="${AGENT_BUILDDIRECTORY}/Java"

export CC=cl.exe
export CXX=cl.exe


ctest -D dashboard_source_config_dir="Wrapping/Java" \
      -D "CTEST_BUILD_NAME:STRING=${AGENT_NAME}-${AGENT_JOBNAME}-java" \
      -D "CTEST_CMAKE_GENERATOR:STRING=Ninja" \
      -S ${BUILD_SOURCESDIRECTORY}/Testing/CI/Azure/azure.cmake -V || echo "##vso[task.logissue type=warning]There was a build or testing issue."

( cd ${CTEST_BINARY_DIRECTORY} && cmake --build "${CTEST_BINARY_DIRECTORY}" --config "${CTEST_CONFIGURATION_TYPE}" --target dist -v )


ls -laR "${CTEST_BINARY_DIRECTORY}/dist"
mkdir -p "${BUILD_ARTIFACTSTAGINGDIRECTORY}/java"
find "${CTEST_BINARY_DIRECTORY}/dist" -name "SimpleITK*.zip" -exec cp -v {} "${BUILD_ARTIFACTSTAGINGDIRECTORY}/java" \;
