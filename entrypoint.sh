#! /bin/bash

export PATH=${HOME}/maintainer-quality-tools/travis:${PATH} 
export TRAVIS_BUILD_DIR="/root/src"
yaml() {  python -c "import yaml;print(yaml.load(open('$1'), Loader=yaml.FullLoader)$2)"; }
cd /root/src
# Get Odoo version to check (normally comes from .travis.cfg)
export TRAVIS_FILE=`pwd -P`/.travis.yml
py_version=2
if [ -f ${TRAVIS_FILE} ]; then
    echo "reading ${TRAVIS_FILE}"
    export VERSION=`grep VERSION .travis.yml | sed -n 's;.*VERSION="\([^"]*\).*;\1;p'`
    export PY_VERSION=$(yaml $TRAVIS_FILE "['python'][0][0]")


else
    echo "Cannot determine the odoo version as ${TRAVIS_FILE} is missing"
    echo "Please specify env vars for python version PY_VERSION and odoo version VERSION"
fi
echo "Testing with Odoo $VERSION using Python $PY_VERSION"
. "/venv_py$PY_VERSION/bin/activate" && travis_run_tests
