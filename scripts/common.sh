#!/bin/bash

BEFORE_CI_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/before_ci.sh"
# shellcheck source=scripts/before_ci.sh
source "${BEFORE_CI_SCRIPT}"

# run the ITs if we have an ENV_VARS are set
if [ "${CI_SECURE_ENV_VARS}" = true ]; then
  RUN_ITS=true
fi
RUN_ITS=${RUN_ITS:-false}

if [ "${RUN_ITS}" = true ] && [ ! "${IS_RELEASE}" = true ]; then
  DEPLOY=true
fi
DEPLOY=${DEPLOY:-false}

# all the prep is done, lets run the build!
MVN_CMD="./mvnw -s settings.xml -B -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn -V"

deploy() {
  echo "Deploying build"
  ${MVN_CMD} clean release:clean
  ${MVN_CMD} clean release:prepare
  ${MVN_CMD} release:perform -DsonatypeUser=developerbhuwan -DsonatypePassword= -Pdocs

  # also deploy the documentation and javadocs to the site
  #  git clone -b gh-pages "https://github.com/${REPO_SLUG}.git" target/gh-pages/
}

full_build() {
  echo "Running mvn install"
  ${MVN_CMD} install sonar:sonar -U -P sonar
}

no_ci_build() {
  echo "Skipping ITs, SonarScan likely this build is a local build"
  ${MVN_CMD} install -DskipITs
}

# run 'mvn release:perform' if we can
if [ "${DEPLOY}" = true ]; then
  deploy
else
  # else try to run the ITs if possible and run Sonar Scan
  if [ "${RUN_ITS}" = true ]; then
    full_build
  else
    # fall back to running an install and skip the ITs and SonarScant
    no_ci_build
  fi
fi
