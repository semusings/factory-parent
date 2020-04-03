#!/bin/bash

BEFORE_CI_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/before_ci.sh"
# shellcheck source=scripts/before_ci.sh
source "${BEFORE_CI_SCRIPT}"

# all the prep is done, lets run the build!
MVN_CMD="./mvnw -s settings.xml -B -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn -V"

deploy() {
  echo "Deploying SNAPSHOT build"
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
