FROM phusion/baseimage:0.9.19

# Standard stuff
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ARG DOCKER_TAG
ENV DOCKER_TAG ${DOCKER_TAG}

ENV APP_ROOT /


ENV ENVIRONMENT DEV

# Dependencies
RUN \
    apt-get update && \
    apt-get install -y \
        build-essential \
        checkinstall \
        pkg-config \
        daemontools \
        git \
        libffi-dev \
        libmysqlclient-dev \
        libssl-dev \
        make \
        python3 \
        python3-dev \
        python3-pip \
        libxml2-dev \
        libxslt-dev \
        runit \
        nginx \
        wget \
        pandoc

# Python 3.6
RUN \
    wget https://www.python.org/ftp/python/3.7.0/Python-3.7.0.tar.xz && \
    tar xvf Python-3.7.0.tar.xz && \
    cd Python-3.7.0/ && \
    ./configure && \
    make altinstall
    sh ./snapshotgen.sh