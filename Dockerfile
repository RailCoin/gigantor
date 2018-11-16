FROM phusion/baseimage:0.9.19

# Standard stuff
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ARG DOCKER_TAG
ENV DOCKER_TAG ${DOCKER_TAG}

ENV APP_ROOT /app
WORKDIR /app

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
        wget \
        pandoc \
        libyajl-dev \
        virtualenv

# copy in everything from repo
COPY . .

RUN chmod +x /app/snapshotgen.sh

# entrypoint
CMD /app/snapshotgen.sh
