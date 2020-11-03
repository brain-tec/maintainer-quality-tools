FROM debian:stretch-slim
LABEL maintainer=""

# Generate locale C.UTF-8 for postgres and general locale data
ENV LANG C.UTF-8
ENV VERSION "11.0"
ENV PY_VERSION "3"
ENV TESTS "0"
ENV LINT_CHECK "1"
ENV TRANSIFEX "0"
RUN apt-get update && apt-get install -y --no-install-recommends python-pip wget python-dev curl \
    && apt-get update && apt-get install -y --no-install-recommends python3-pip wget python3-dev curl \
    && rm -rf /var/lib/apt/lists/*
RUN pip install setuptools wheel
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get update && apt-get install -y git nodejs \
    && rm -rf /var/lib/apt/lists/*
RUN mkdir /root/maintainer-quality-tools
COPY ./travis /root/maintainer-quality-tools/travis
COPY ./cfg /root/maintainer-quality-tools/cfg
COPY ./tests /root/maintainer-quality-tools/tests
RUN  echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" > etc/apt/sources.list.d/pgdg.list \
        && export GNUPGHOME="$(mktemp -d)" \
        && repokey='B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8' \
        && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${repokey}" \
        && gpg --armor --export "${repokey}" | apt-key add - \
        && gpgconf --kill all \
        && rm -rf "$GNUPGHOME" \
        && apt-get update -qq \
        && apt-get install -yqq postgresql-9.6
RUN pip --no-cache-dir install virtualenv pyyaml  && virtualenv --system-site-packages -p python3 venv_py3 && virtualenv --system-site-packages venv_py2
RUN export PATH=${HOME}/maintainer-quality-tools/travis:${PATH} \
    && . venv_py3/bin/activate && pip3 --no-cache-dir install -I pyyaml coverage && travis_install_nightly
RUN export PATH=${HOME}/maintainer-quality-tools/travis:${PATH} \
    && . venv_py2/bin/activate && pip --no-cache-dir install -I  pyyaml coverage && travis_install_nightly
# install a venv for py3


RUN apt-get update && apt-get install -yqq expect python-coverage python3-coverage
RUN pip3 install coverage
RUN mkdir /root/src
VOLUME ["/root/src"]
RUN cd /usr/bin && ln -s /root/maintainer-quality-tools/travis/travis_run_tests
COPY ./entrypoint.sh /entrypoint.sh

# enable eslint's es6 support
COPY sample_files/pre-commit-13.0/.eslintrc.yml /root/.eslintrc.yml
ENV PYLINT_ODOO_JSLINTRC /root/.eslintrc.yml
CMD ["/entrypoint.sh"]
