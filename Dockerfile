FROM ghcr.io/anomalyco/opencode:2.2.7

ARG HOME=/workspace

#ARG ARM_DEV_TOOLS="binutils-arm-none-eabi gcc-arm-none-eabi newlib-arm-none-eabi picolibc-arm-none-eabi"
ARG DEV_TOOLS="build-base catch2 cmake git make"
ARG UTILS="bash 7zip curl gawk gzip file jq pigz pixz ripgrep unzip wget xz"
ARG NODEJS="nodejs npm"
ARG PYTHON="py3-cryptography py3-numpy py3-pillow py3-pip py3-pyserial   python3"
ARG CRYPTO="openssl py3-cryptography"
#ARG GLIBC_COMPAT="gcompat libstdc++"

RUN sed -i 's/^#\(.*community\)/\1/' /etc/apk/repositories && \
    apk update && \
    apk add --no-cache $CRYPTO $DEV_TOOLS $NODEJS $PYTHON $UTILS

WORKDIR $HOME

COPY --chown=1000:1000 --parents .config .

RUN adduser -D -u 1000 -g 1000 -h $HOME user && \
    mkdir -p /tmp/opencode && \
    chown user /tmp/opencode

USER user
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$HOME/.local/bin:$HOME/.bun/bin:$HOME/node_modules/.bin

COPY --chown=1000:1000 --chmod=0555 scripts .
RUN ./setup.sh

ENV OPENCODE_DISABLE_MODELS_FETCH=1
ENV OPENCODE_DISABLE_FREE_MODELS=1
