+++
title = "Build Carla from source using Docker"
date = 2023-12-13
author = "BOULBALAH Lahcen"
tags = ["Docker","carla","PythonAPI"]
keywords = ["carla", "Docker","Container","Build"]
description = "Building Carla from source using Docker to simplifie the build"
showFullContent = false
+++

## Introduction

- In this article, I will discuss the process of constructing Carla PythonAPI or building Carla from source using a Dockerfile. The aim is to streamline the procedure and circumvent various issues that may arise when attempting to build it on a conventional host machine.



### Brief introducation about Docker

  `Docker` is  Docker is a platform that simplifies software development by packaging applications and their dependencies into `containers`. 
  `Containers` are lightweight, portable, and enable consistent deployment across different environments. With Docker, developers can create, share, and run applications seamlessly. 
  Docker uses `images`, defined by `Dockerfiles`, to build these portable units. The `Docker Engine` manages containers, offering isolation and resource efficiency.
 
Example of Dockerfile  

```docker
  # Use the official Ubuntu 18.04 base image
FROM ubuntu:18.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install required dependencies
RUN apt-get update && \
    apt-get install -y \
    software-properties-common \
    sudo \
    build-essential \
    cmake \
    git \
    wget \
    unzip \
    python3 \
    python3-pip \
    libpng16-16 \
    libtiff5 \
    libjpeg8 \
    libgtk-3-0 \
    libegl1-mesa \
    libxrandr2 \
    libxinerama1 \
    libxcursor1 \
    libxcomposite1 \
    libglu1-mesa \
    libopenal1 \
    libsndfile1 \
    libxi6 \
    libgconf-2-4 \
    libboost-all-dev

# Clone CARLA from the official repository
RUN git clone https://github.com/carla-simulator/carla.git /opt/carla

# Build CARLA
WORKDIR /opt/carla
RUN ./Setup.sh && \
    ./Build.sh

# Expose ports
EXPOSE 2000-2002

# Set the entry point for CARLA
ENTRYPOINT ["./CarlaUE4.sh", "-opengl"]

# Specify the default command to run on container startup
CMD ["--no-rendering", "-quality-level=Epic"]

```

To create and execute a Docker image using the supplied Dockerfile for CARLA, you can proceed with the following steps:

1- save the dockerfile
2- Build the Docker image by entering the following command in your terminal:

``` bash
    docker build -t carla-simulator .

```

3- Run the Docker container with the specified ports using the following command:

``` bash 
    docker run -p 2000-2002:2000-2002 --name carla-container carla-simulator

```
4- To verify that the container is running, execute the following command:

```bash
    docker ps
```
### Building carla from source using the Dockerfile

In this segment, we'll delve into a comprehensive approach to assemble all the essential dependencies required for building CARLA from source. The motivation behind this is to construct CARLA from source, enabling its utilization across various architectures such as ARM and accommodating diverse use cases. Our Dockerfile is specifically tailored for PythonAPI, facilitating the construction from source to generate both the .egg file and .whl file. Should you wish to build CARLA along with PythonAPI, simply uncomment the relevant section to include it in the image.

The forthcoming Dockerfile is instrumental in crafting our image for the prerequisites necessary to initiate the build process. Essentially, we'll be creating two distinct images – one for dependencies and the other for the build itself.
let's start by the first one.

 
```Dockerfile
FROM ubuntu:18.04

USER root

#ARG EPIC_USER=user
#ARG EPIC_PASS=pass
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update ; \
  apt-get install -y wget software-properties-common && \
  add-apt-repository ppa:ubuntu-toolchain-r/test && \
  wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|apt-key add - && \
  apt-add-repository "deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-8 main" && \
  apt-get update ; \
  apt-get install -y build-essential \
    clang-8 \
    lld-8 \
    g++-7 \
    cmake \
    ninja-build \
    libvulkan1 \
    python \
    python-pip \
    python-dev \
    python3-dev \
    python3-pip \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    tzdata \
    sed \
    curl \
    unzip \
    autoconf \
    libtool \
    rsync \
    libxml2-dev \
    git \
    aria2 && \
  pip3 install -Iv setuptools==47.3.1 && \
  pip3 install distro && \
  update-alternatives --install /usr/bin/clang++ clang++ /usr/lib/llvm-8/bin/clang++ 180 && \
  update-alternatives --install /usr/bin/clang clang /usr/lib/llvm-8/bin/clang 180

RUN useradd -m carla
COPY --chown=carla:carla . /home/carla
USER carla
WORKDIR /home/carla
ENV UE4_ROOT /home/carla/UE4.26

#RUN git clone --depth 1 -b carla "https://${EPIC_USER}:${EPIC_PASS}@github.com/CarlaUnreal/UnrealEngine.git" ${UE4_ROOT}

#RUN cd $UE4_ROOT && \
#  ./Setup.sh && \
#  ./GenerateProjectFiles.sh && \
#  make

WORKDIR /home/carla/

```
In this Dockerfile, we incorporate all the dependencies and set a working directory to organize our components, including the CARLA source code for the subsequent Dockerfile. Let's designate a name for this file, such as `tools.Dockerfile`. Now, we proceed to create our image using the following command:

```bash
    docker build --tag rerequisites -f tools.Dockerfile
```
By executing this command, we will create the image with the name: `prerequisites` .

After building it, let's create another Dockerfile for the build process and clone the CARLA source code from GitHub.

```Docker

FROM carla-prerequisites:latest

ARG TAG_NAME

USER carla
WORKDIR /home/carla

RUN cd /home/carla/ && \
    git clone --depth 1 --branch ${TAG_NAME} https://github.com/carla-simulator/carla.git && \
    cd /home/carla/carla && \
#  ./Update.sh && \
#  make CarlaUE4Editor && \
    make PythonAPI 
#  make build.utils && \
#  make package && \
WORKDIR /home/carla/carla

```
In this Dockerfile, we clone the CARLA source file. Be sure to specify a `TAG_NAME`, such as 0.9.12, which can be found in the official CARLA repository on GitHub to clone a specific version for building from source. Following this, we proceed to build the image, adhering to the usual steps:

1- Save the file initially with a name like `carla.Dockerfile`

2- Build the image using the following command:

 ```bash
    docker build --tag carlaarm -f carla.Dockerfile
```
3- wait until the build complet 

Subsequently, execute a container from the built image using this command:

```bash
    docker run -it carlaarm:latest bash

```
Once inside the container, navigate to the `PythonAPI/carla/dist`. Here, you'll find the desired `.egg` and `.whl` files. To easily copy them to your host machine, employ the following command:

Initially, retrieve the container `ID` by executing the following command:

```bash
    docker ps
```
Copy the container `ID`, and now let's proceed to copy the necessary files from the container using the following command:

```bash
    docker cp container_id:/hom/carla/carla/PythonAPI  dist_path
```
`dist_path: in your host machine to save the file in`

Voilà! Congratulations, you have successfully built the PythonAPI from source. You can follow the same process for building CARLA entirely, not just the PythonAPI, by uncommenting the relevant sections in the Dockerfile. Keep in mind that building the entire CARLA may take a longer time and require more space :)

# Troublshoting

Certainly, encountering issues during the build process is not uncommon. In the context of building the `.egg` file for an `ARM` architecture, one notable challenge arises when downloading the source code from the CARLA GitHub repository. Specifically, a library may fail to install due to a `URL`-related issue.

To address this, a potential solution involves navigating to the source code and locating the file at the path `Util/BuildTools/Setup.sh`. Once there, proceed to line `432` and modify the REPO_URL to resolve the URL-related problem. This adjustment can often overcome installation hurdles associated with ARM architecture builds.

```sh 
    XERCESC_REPO=https://ftp.cixug.es/apache//xerces/c/3/sources/xerces-c-${XERCESC_VERSION}.tar.gz to 
    XERCESC_REPO=https://archive.apache.org/dist/xerces/c/3/sources/xerces-c-${XERCESC_VERSION}.tar.gz
```

It's valuable to note that the mentioned issue appears in CARLA version `0.9.13`, and it's recommended to check if similar challenges persist in other versions.

Another issue that may arise during the PythonAPI build is encountering a compatibility warning, such as `0.9.13-dirty`. To address this, navigate to the `Setup.sh` file in the same path `(Util/BuildTools/Setup.sh)`. Making adjustments in this file can help resolve compatibility version warnings and ensure a smoother experience with the PythonAPI.

```sh 
    CARLA_VERSION=$(get_git_repository_version)
```
i force the `CARLA_VERSION` to be the tagge i want to build like 

```sh 
    CARLA_VERSION=0.9.13
```
Welcome to the world of intricate software development – where navigating through such challenges is all part of the journey!

And after rebuilding the image, voilà, everything works! However, remember to include the specific version of CARLA you've cloned to override potential issues. Mixing versions can lead to compatibility problems.

## Conclusion:
 
In summary, building CARLA's PythonAPI from source involves meticulous Dockerfile configurations, addressing version-specific challenges, and resolving compatibility warnings. Navigating these intricacies leads to a robust development environment and a gratifying coding experience. Happy coding!

## Resources:

- [Dockerfile used in this article ](https://github.com/misarb/CarlaBuild)
- [Carla doc](https://carla.readthedocs.io/en/0.9.14/)
- [Dockerdoc](https://docs.docker.com/)


