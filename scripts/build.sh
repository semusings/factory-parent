#!/bin/bash

source "${COMMON_SCRIPT}"
COMMON_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"
# shellcheck source=scripts/common.sh
source "${COMMON_SCRIPT}"

release_prepare() {

  echo "Preparing release"
  ${MVN_CMD} clean release:prepare

}

compile() {

  echo "Rollback release"
  ${MVN_CMD} clean compile

}

deploy() {

  echo "Performing release"
  ${MVN_CMD} clean release:perform \
    -DsonatypeUser="${SONATYPE_USER}" \
    -DsonatypePassword="${SONATYPE_PASSWORD}"

  # also deploy the documentation and javadocs to the site
  #  git clone -b gh-pages "https://github.com/${REPO_SLUG}.git" target/gh-pages/

}

full_build() {

  echo "Running full_build ${SONAR_BRANCH}"
  ${MVN_CMD} install sonar:sonar sonar-quality-gate:check -U -P sonar \
    -DsonarOrganization="${SONAR_ORGANIZATION}" \
    -DsonarHost="${SONAR_HOST}" \
    -DsonarLogin="${SONAR_LOGIN}" \
    -DsonarBranch="${SONAR_BRANCH}"

}

no_ci_build() {

  echo "Skipping ITs, SonarScan likely this build is a local build"
  ${MVN_CMD} install -DskipITs
  echo ""
  echo "To run full_build and deploy set environments"
  echo "Sonar Vars: SONAR_ORGANIZATION, SONAR_HOST, SONAR_LOGIN"
  echo "Sonatype Vars: SONATYPE_USER, SONATYPE_PASSWORD"
  echo ""

}

# run 'mvn release:perform' if we can
if [ "${DEPLOY}" = true ]; then
  release_prepare
  release
else
  if [ "${RUN_ITS}" = true ]; then
    full_build
  else
    # fall back to running an install and skip the ITs and SonarScan
    if [ "${IS_COMPILE}" = true ]; then
      compile
    else
      # fall back to running an install and skip the ITs and SonarScan
      no_ci_build
    fi
  fi
fi
