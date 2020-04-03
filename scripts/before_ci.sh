#!/bin/bash

#Using cat is faster than invoking maven
ARTIFACT_VERSION="$(cat pom.xml | grep '<version>' | head -1 | sed 's/ //g' | sed 's/<version>//g' | sed 's/<\/version>//g' | sed 's/\s//g')"
IS_RELEASE=$([ "${ARTIFACT_VERSION/SNAPSHOT}" == "${ARTIFACT_VERSION}" ] && echo 'true')
export ARTIFACT_VERSION
export IS_RELEASE

echo "Build configuration:"
echo "Version:             ${ARTIFACT_VERSION}"
echo "Is release:          ${IS_RELEASE:-false}"
echo
echo "Java Version:"
java -version