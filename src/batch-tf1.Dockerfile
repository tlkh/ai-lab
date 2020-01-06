# Base image:
# https://ngc.nvidia.com/catalog/containers/nvidia:tensorflow
# Build this Dockerfile and tag as:
# nvaitc/ai-lab:xx.xx-batch

FROM nvaitc/ai-lab:20.01-batch-base

LABEL maintainer="Timothy Liu <timothyl@nvidia.com>"

USER root

ENV DEBIAN_FRONTEND=noninteractive \
    TF_FORCE_GPU_ALLOW_GROWTH=true

ENV TENSORFLOW_URL=https://github.com/tlkh/getcuda/releases/download/0c/tensorflow-2.0.0-cp36-cp36m-linux_x86_64.whl \
    TENSORFLOW_FILENAME=tensorflow-2.0.0-cp36-cp36m-linux_x86_64.whl

RUN cd /tmp/ && \
    wget -O ${TENSORFLOW_FILENAME} ${TENSORFLOW_URL} && \
    pip install --no-cache-dir --ignore-installed PyYAML \
      tensorflow_datasets \
      tensorflow-hub \
      && \
    pip uninstall tensorflow tensorflow-gpu -y && \
    pip uninstall opencv-python opencv-contrib-python -y && \
    pip install --no-cache-dir opencv-contrib-python && \
    pip install --no-cache-dir ${TENSORFLOW_FILENAME} && \
    cd $HOME && \
    rm -rf /tmp/* && \
    rm -rf $HOME/.cache

USER root

ENV HOROVOD_GPU_ALLREDUCE=NCCL \
    HOROVOD_WITH_TENSORFLOW=1 \
    HOROVOD_WITH_PYTORCH=1

RUN apt-get update && \
    apt-get install -yq --no-upgrade \
      openssh-client \
      openssh-server \
      libopenmpi-dev \
      libomp-dev \
      librdmacm1 \
      libibverbs1 \
      ibverbs-providers && \
    mkdir /tmp/openmpi && \
    cd /tmp/openmpi && \
    wget https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-4.0.2.tar.gz && \
    tar zxf openmpi-4.0.2.tar.gz && \
    cd openmpi-4.0.2 && \
    ./configure --enable-orterun-prefix-by-default && \
    make -j $(nproc) all && \
    make install && \
    ldconfig && \
    ldconfig /usr/local/cuda/targets/x86_64-linux/lib/stubs && \
    apt-get autoremove -y && \
    apt-get clean && \
    cd /tmp/* && \
    rm -rf /tmp/* && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/* && \
    rm -rf $HOME/.cache

USER root

RUN pip install --no-cache-dir horovod && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/* && \
    rm -rf /tmp/* && \
    rm -rf $HOME/.cache

RUN ldconfig && \
    mv /usr/local/bin/mpirun /usr/local/bin/mpirun.real && \
    echo '#!/bin/bash' > /usr/local/bin/mpirun && \
    echo 'mpirun.real --allow-run-as-root "$@"' >> /usr/local/bin/mpirun && \
    chmod a+x /usr/local/bin/mpirun && \
    echo "hwloc_base_binding_policy = none" >> /usr/local/etc/openmpi-mca-params.conf && \
    echo "rmaps_base_mapping_policy = slot" >> /usr/local/etc/openmpi-mca-params.conf && \
    echo "btl_tcp_if_exclude = lo,docker0" >> /usr/local/etc/openmpi-mca-params.conf && \
    echo NCCL_DEBUG=INFO >> /etc/nccl.conf && \
    mkdir -p /var/run/sshd && \
    cat /etc/ssh/ssh_config | grep -v StrictHostKeyChecking > /etc/ssh/ssh_config.new && \
    echo "    StrictHostKeyChecking no" >> /etc/ssh/ssh_config.new && \
    mv /etc/ssh/ssh_config.new /etc/ssh/ssh_config

