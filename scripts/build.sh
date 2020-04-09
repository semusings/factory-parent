#!/bin/bash

COMMON_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"
# shellcheck source=scripts/common.sh
source "${COMMON_SCRIPT}"

compile() {

  echo "Rollback release"
  ${MVN_CMD} clean compile

}

deploy() {

  echo "Performing release"
  ${MVN_CMD} clean release:prepare release:perform \
    -DsonatypeUser="${SONATYPE_USER}" \
    -DsonatypePassword="${SONATYPE_PASSWORD}"

  # also deploy the documentation and javadocs to the site
  #  git clone -b gh-pages "https://github.com/${REPO_SLUG}.git" target/gh-pages/

}

rollback() {

  echo "Rollback release"
  ${MVN_CMD} clean release:rollback

}

docs() {

  echo "Running docs"
  ${MVN_CMD} clean install -DskipTests -DskipITs -Pdocs

}

full_build() {

  echo "Running full_build ${SONAR_BRANCH}"
  ${MVN_CMD} clean install sonar:sonar -U -P sonar \
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
  echo "Common Vars: CI_SECURE_ENV_VARS"
  echo "To build: SONAR_ORGANIZATION, SONAR_HOST, SONAR_LOGIN"
  echo "To release: PULL_REQUEST, SONATYPE_USER, SONATYPE_PASSWORD"
  echo "To rollback release: IS_ROLLBACK"
  echo "To build documentation: IS_DOCS"
  echo ""

}

# run 'mvn release:perform' if we can
if [ "${DEPLOY}" = true ]; then
  deploy
else
  if [ "${IS_ROLLBACK}" = true ]; then
    rollback
  else
    if [ "$IS_DOCS" ]; then
      docs
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
  fi
fi
