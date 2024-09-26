#!/bin/bash
setup() {
  set -eu -o pipefail
  export DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )/.."
  export TESTDIR=~/tmp/test-addon-backstopjs
  mkdir -p $TESTDIR
  export PROJNAME=test-addon-backstopjs
  export DDEV_NON_INTERACTIVE=true
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1 || true
  cd "${TESTDIR}"
  ddev config --project-name=${PROJNAME} --project-type=php
  ddev get metadrop/ddev-aljibe
  ddev start -y >/dev/null
  ddev aljibe-assistant --auto
}

teardown() {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1
  [ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR}
}

check_installed () {
  # backstop is installed and can show its version
  echo "Checking backstopjs version with `ddev backstopjs local version`" >&3
  ddev backstopjs local version | grep 'Command "version" successfully executed' >&3
}

check_backstopjs () {
  # Create reference bitmaps
  echo "Creating backstopjs references with `ddev backstopjs local reference`" >&3
  ddev backstopjs local reference >&3
  # Test should pass because there is a reference bitmaps
  echo "Testing backstopjs references with `ddev backstopjs local test`" >&3
  ddev backstopjs local test >&3
}

@test "Install latest commit" {
  set -eu -o pipefail
  cd ${TESTDIR}
  echo "# ddev get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get ${DIR}
  echo "Installed add-on from directory, restarting ddev" >&3
  ddev restart
  echo "Testing backstopjs" >&3
  check_installed
  check_backstopjs
}


#@test "Install latest release version" {
#  set -eu -o pipefail
#  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
#  echo "Aljibe already have the release version, running tests now"
#  echo "Testing backstopjs" >&3
#  check_installed
#  check_backstopjs
#}
