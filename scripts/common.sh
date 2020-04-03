#!/bin/bash

BEFORE_CI_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/before_ci.sh"
# shellcheck source=scripts/before_ci.sh
source "${BEFORE_CI_SCRIPT}"

# deploy snapshot from ONLY this branch
SNAPSHOT_BRANCH="master"

# run the ITs if we have an ENV_VARS are set
if [ "${CI_SECURE_ENV_VARS}" = true ]; then
  RUN_ITS=true
fi
RUN_ITS=${RUN_ITS:-false}

if [ "${RUN_ITS}" = true ] && [ ! "${IS_RELEASE}" = true ] && [ "$BRANCH" = "$SNAPSHOT_BRANCH" ]; then
  IS_GIT_RELEASE=true
fi
IS_GIT_RELEASE=${IS_GIT_RELEASE:-false}

# all the prep is done, lets run the build!
MVN_CMD="./mvnw -s settings.xml -B -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn -V"

release_prepare() {

  echo "Preparing release"
  ${MVN_CMD} clean release:prepare

}

release_rollback() {

  echo "Rollback release"
  ${MVN_CMD} clean release:rollback

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

  echo "Running mvn install"
  ${MVN_CMD} install sonar:sonar -U -P sonar \
    -DsonarOrganization="${SONAR_ORGANIZATION}" \
    -DsonarHost="${SONAR_HOST}" \
    -DsonarLogin="${SONAR_LOGIN}" \
    -DsonarBranch="${BRANCH}"

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
if [ "${IS_GIT_RELEASE}" = true ]; then
  release_prepare
  release
else
  if [ "${RUN_ITS}" = true ]; then
    full_build
  else
    # fall back to running an install and skip the ITs and SonarScan
    no_ci_build
  fi
fi
