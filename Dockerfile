# syntax=docker/dockerfile:1
# Use the official Debian image as the base image
FROM ubuntu:22.04 
#FROM debian:bookworm AS build

# Set the maintainer label (optional)
LABEL maintainer="jean.sachin94@gmail.com"

WORKDIR /work

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && apt-get install -y \
    build-essential \
    vim \
    cmake \
    curl \
    wget \
    rsync \
    git \
    mono-complete \
    dotnet-sdk-6.0 \
    #gcc \
    #g++ \
    libnotify-dev \
    notify-osd \
    libglib2.0-dev \
    libasound2-dev \
    libappindicator3-dev \
    python2 \
    pip

RUN mkdir ~/.dotnet && \
    ln -s /usr/bin/dotnet ~/.dotnet/dotnet && \
    ln -s /usr/bin/python2 /usr/bin/python
    #  - gtk+-3-dev
    #&& rm -rf /var/lib/apt/lists/*

# Expose a port (if needed, optional)
EXPOSE 8080

# Define the default command (optional)
CMD ["bash"]
    


