FROM python:3.12-slim-bookworm

# The OpenDXL Python client. The PyPI release (5.6.0.x) pins msgpack<1.0
# (vulnerable, GHSA-6v7p-g79w-8964) and does not work on current Python
# versions; override with a pip requirement specifier once a fixed release
# is published.
ARG DXL_CLIENT_PIP_SPEC="git+https://github.com/derjochenmueller/opendxl-client-python@epo-legacy"
ARG DXL_BOOTSTRAP_VERSION=0.2.2
ARG CLOUDCMD_VERSION=^19.0.0
ARG GRITTY_VERSION=^10.0.0
ARG NODE_SETUP=setup_22.x

VOLUME ["/opendxl"]

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl git unzip wget telnet vim gnupg iproute2 ca-certificates \
        openjdk-17-jdk-headless build-essential \
    && curl -fsSL https://deb.nodesource.com/${NODE_SETUP} | /bin/bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && npm install -g cloudcmd@${CLOUDCMD_VERSION} gritty@${GRITTY_VERSION} bootprint bootprint-opendxl \
    && npm cache clean --force \
    && apt-get remove -y --auto-remove build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /root/dxlschema/v0.1 \
    && cd /root/dxlschema/v0.1 \
    && wget https://opendxl.github.io/opendxl-api-specification/v0.1/schema.json

RUN pip install --no-cache-dir sphinx "${DXL_CLIENT_PIP_SPEC}" dxlbootstrap==${DXL_BOOTSTRAP_VERSION} twine jsonschema

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

ENTRYPOINT ["/dxlenvironment/startup.sh"]
