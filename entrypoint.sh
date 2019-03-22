#! /bin/bash

export PATH=${HOME}/maintainer-quality-tools/travis:${PATH} 
export TRAVIS_BUILD_DIR="/root/src"
cd /root/src
# Get Odoo version to check (normally comes from .travis.cfg)
export TRAVIS_FILE=`pwd -P`/.travis.yml
if [ -f ${TRAVIS_FILE} ]; then
    echo "reading ${TRAVIS_FILE}"
    export VERSION=`grep VERSION .travis.yml | sed -n 's;.*VERSION="\([^"]*\).*;\1;p'`
    echo "Testing with version: $VERSION"
else
    echo "Cannot determine the odoo version as ${TRAVIS_FILE} is missing"
fi

travis_run_tests
