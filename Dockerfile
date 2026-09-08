FROM python:3.12-slim-bookworm

# The OpenDXL Python client. The PyPI release (5.6.0.x) pins msgpack<1.0
# (vulnerable, GHSA-6v7p-g79w-8964) and does not work on current Python
# versions; override with a pip requirement specifier once a fixed release
# is published.
ARG DXL_CLIENT_PIP_SPEC="git+https://github.com/JMuellerTX/opendxl-client-python@epo-legacy"
# The dxlbootstrap release on PyPI imports pkg_resources, which setuptools 82
# dropped and a current base image no longer provides, so anything built on it
# fails at import. The fork uses importlib.resources instead.
ARG DXL_BOOTSTRAP_PIP_SPEC="git+https://github.com/JMuellerTX/opendxl-bootstrap-python@master"
# The bootprint-opendxl release on npmjs.com is the upstream 0.1.4, which
# depends on bootprint 1.x from 2016 and everything under it. The fork moved
# to bootprint 4; it is not on npmjs.com, because that name belongs to the
# upstream project, so it is installed from its release tarball instead.
ARG BOOTPRINT_OPENDXL_TARBALL="https://github.com/JMuellerTX/bootprint-opendxl/releases/download/v0.1.4%2Bfork.1/bootprint-opendxl-0.1.4%2Bfork.1.tgz"
ARG CLOUDCMD_VERSION=^19.0.0
ARG GRITTY_VERSION=^10.0.0
ARG NODE_SETUP=setup_22.x

VOLUME ["/opendxl"]

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl git unzip wget telnet vim gnupg iproute2 ca-certificates \
        openjdk-17-jdk-headless build-essential \
    && curl -fsSL https://deb.nodesource.com/${NODE_SETUP} | /bin/bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && npm install -g cloudcmd@${CLOUDCMD_VERSION} gritty@${GRITTY_VERSION} bootprint "${BOOTPRINT_OPENDXL_TARBALL}" \
    && npm cache clean --force \
    && apt-get remove -y --auto-remove build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /root/dxlschema/v0.1 \
    && cd /root/dxlschema/v0.1 \
    && wget https://opendxl.github.io/opendxl-api-specification/v0.1/schema.json

RUN pip install --no-cache-dir sphinx "${DXL_CLIENT_PIP_SPEC}" "${DXL_BOOTSTRAP_PIP_SPEC}" twine jsonschema

COPY files/.bashrc /root
COPY files/vimrc.local /etc/vim
COPY files/edit.json /usr/lib/node_modules/cloudcmd/node_modules/edward/json/
COPY dxlenvironment /dxlenvironment

ENV cloudcmd_contact false
ENV cloudcmd_console false
ENV cloudcmd_one_panel_mode true
ENV cloudcmd_terminal true
ENV cloudcmd_terminal_path gritty

EXPOSE 8000

# This image runs as root, unlike the service images in this project, and that
# is deliberate rather than an oversight. It is a development sandbox: the
# entrypoint writes the docker host into /etc/hosts, and the whole point of the
# console is a terminal and a file manager that can install packages and edit
# files anywhere in the container. A USER here would take away what the image
# is for.
#
# The consequence is worth stating plainly: the console on port 8000 has no
# authentication, so publishing it as `-p 8000:8000` gives anyone who can reach
# that port a root shell in the container. Publish it to the loopback interface
# instead:
#
#     docker run -p 127.0.0.1:8000:8000 ...
#
# Cloud Commander reads its settings from the environment, so a shared instance
# can be given credentials without rebuilding:
#
#     -e cloudcmd_auth=true -e cloudcmd_username=... -e cloudcmd_password=...
ENTRYPOINT ["/dxlenvironment/startup.sh"]
