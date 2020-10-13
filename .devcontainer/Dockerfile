ARG VARIANT="2"
FROM ruby:${VARIANT}-alpine

ARG USER_UID="1000"
ARG USER_GID="1000"

RUN echo "root:root" | chpasswd
RUN addgroup -g $USER_GID vscode

RUN adduser -S -u $USER_UID -G vscode vscode \
    && echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && echo "vscode:vscode" | chpasswd

RUN echo "Set disable_coredump false" >> /etc/sudo.conf

RUN apk add sudo

RUN gem update --system
RUN gem install --no-document --force bundler -v 2.1.4

RUN apk update && \
    apk upgrade && \
    apk add --no-cache \
        gcc \
        g++ \
        libc-dev \
        libxml2-dev \
        linux-headers \
        make \
        git \
        vim \
        nodejs \
        postgresql \
        postgresql-dev \
        tzdata \
        yarn && \
    apk add --virtual build-packs --no-cache \
        build-base \
        curl-dev

        

# ImageMagick
RUN apk add --no-cache imagemagick bash pngcrush optipng=0.7.7-r0 ghostscript-fonts

WORKDIR /workspace
