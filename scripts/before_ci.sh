#!/bin/bash

#Using cat is faster than invoking maven
ARTIFACT_VERSION="$(cat pom.xml | grep '<version>' | head -1 | sed 's/ //g' | sed 's/<version>//g' | sed 's/<\/version>//g' | sed 's/\s//g')"
REPO_SLUG=${REPO_SLUG:-$(git remote get-url origin | sed 's_.*\:__; s_.*github.com/__; s_\.git__')}
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
IS_RELEASE=$([ "${ARTIFACT_VERSION/SNAPSHOT/}" == "${ARTIFACT_VERSION}" ] && [ "${BRANCH}" == "master" ] && echo 'true')

echo "Build configuration:"
echo "Version:             ${ARTIFACT_VERSION}"
echo "Is release:          ${IS_RELEASE:-false}"
echo "Branch:              ${BRANCH}"
echo "Slug:                ${REPO_SLUG}"
echo
echo "Java Version:"
java -version
