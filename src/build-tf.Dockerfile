FROM nvaitc/ai-lab:19.07

LABEL maintainer="Timothy Liu <timothyl@nvidia.com>"

USER root

ENV DEBIAN_FRONTEND noninteractive

# Install all OS dependencies

RUN apt-get update && \
    apt-get install -yq \
    python3-dev \
    python3-numpy \
    python3-six \
    python3-pip \
    python3-wheel \
    python3-setuptools \
    # for bazel
    pkg-config zip g++ zlib1g-dev unzip python \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/*

ENV BAZEL_URL https://github.com/bazelbuild/bazel/releases/download/0.24.1/bazel-0.24.1-installer-linux-x86_64.sh

RUN wget ${BAZEL_URL} -O bazel.sh && \
    chmod +x bazel.sh && \
    bash bazel.sh && \
    bazel && \
    rm -rf bazel.sh

WORKDIR $HOME

USER $NB_UID