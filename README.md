[![Actions Status](https://github.com/opendxl/opendxl-environment/workflows/Build/badge.svg)](https://github.com/opendxl/opendxl-environment/actions)
[![Docker Build Status](https://img.shields.io/docker/cloud/build/opendxl/opendxl-environment.svg)](https://hub.docker.com/r/opendxl/opendxl-environment/)

# OpenDXL Environment

## Overview

The OpenDXL Environment is a pre-configured environment available as a [Docker](https://www.docker.com/) image that supports the development and running of OpenDXL solutions. 

The OpenDXL Environment is based on the [Debian operating system](https://www.debian.org/) and includes standard tools and libraries that are commonly used to develop and run OpenDXL solutions. The environment also includes a [web front-end](https://github.com/opendxl/opendxl-environment/wiki/Console-Overview) based on [Cloud Commander](http://cloudcmd.io/) that supports browser-based file management, file editing, and terminal access.

The environment supports:
* Python 3
* Java (JDK 17)
* Node.js (Node 22)

The goal of the OpenDXL Environment is to provide a consistent way to develop OpenDXL solutions across platforms and eliminate the need to manually install commonly used tools (git, wget, curl, etc.) and libraries ([OpenDXL Python Client](https://github.com/opendxl/opendxl-client-python), [OpenDXL Bootstrap](https://github.com/opendxl/opendxl-bootstrap-python)).

The OpenDXL Environment Docker image is available at the following location within [Docker Hub](https://hub.docker.com):

[https://hub.docker.com/r/opendxl/opendxl-environment/](https://hub.docker.com/r/opendxl/opendxl-environment/)

## Running it safely

The console provides **file management, file editing and terminal access, with
no authentication**, and the container runs as root - both by design, because
this is a development sandbox rather than a service. Together they mean that
anyone who can reach port 8000 has a root shell inside the container.

Publish it to the loopback interface, not to every interface:

```bash
docker run -d -p 127.0.0.1:8000:8000 opendxl/opendxl-environment
```

If it has to be reachable from elsewhere, give Cloud Commander credentials -
it reads them from the environment, so no rebuild is needed:

```bash
docker run -d -p 8000:8000 \
  -e cloudcmd_auth=true -e cloudcmd_username=<user> -e cloudcmd_password=<password> \
  opendxl/opendxl-environment
```

## Documentation

See the [Wiki](https://github.com/opendxl/opendxl-environment/wiki) for installation, configuration, usage instructions, and tutorials for the OpenDXL Environment.

## Bugs and Feedback

For bugs, questions and discussions please use the [GitHub Issues](https://github.com/opendxl/opendxl-environment/issues).

## LICENSE

Copyright 2017 McAfee, Inc.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this file except in compliance with the License. You may obtain a copy of the
License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied. See the License for the
specific language governing permissions and limitations under the License.
