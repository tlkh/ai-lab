# Base image:
# https://ngc.nvidia.com/catalog/containers/nvidia:tensorflow
# Build this Dockerfile and tag as:
# nvaitc/ai-lab:xx.xx-batch

FROM nvcr.io/nvidia/tensorflow:19.10-py3

LABEL maintainer="Timothy Liu <timothyl@nvidia.com>"

USER root

ENV DEBIAN_FRONTEND=noninteractive \
    TF_FORCE_GPU_ALLOW_GROWTH=true

ENV TENSORFLOW_URL=https://github.com/tlkh/getcuda/releases/download/0d/tensorflow-2.0.0-cp36-cp36m-linux_x86_64.whl \
    TENSORFLOW_FILENAME=tensorflow-2.0.0-cp36-cp36m-linux_x86_64.whl \ 
    PYTORCH_URL=https://download.pytorch.org/whl/cu101/torch-1.3.1-cp36-cp36m-linux_x86_64.whl \
    PYTORCH_FILENAME=torch-1.3.1-cp36-cp36m-linux_x86_64.whl

ADD requirements.txt /tmp/requirements.txt

RUN cd /tmp/ && \
    pip install --no-cache-dir pip setuptools wheel -U && \
    pip install --no-cache-dir -r /tmp/requirements.txt && \
    wget -O ${TENSORFLOW_FILENAME} ${TENSORFLOW_URL} && \
    wget -O ${PYTORCH_FILENAME} ${PYTORCH_URL} && \
    pip uninstall tensorflow tensorflow-gpu -y && \
    pip install --no-cache-dir ${TENSORFLOW_FILENAME} ${PYTORCH_FILENAME} && \
    pip install --no-cache-dir --ignore-installed PyYAML \
      tensorflow-io \
      tensorflow-addons \
      tensorflow_datasets \
      tensorflow-hub \
      tensorflow-probability \
      keras-tuner \
      tensorflow-model-optimization \
      && \
    git clone --depth 1 https://github.com/huggingface/transformers && \
    cd /tmp/transformers && \
    pip install . && \
    cd $HOME && \
    pip uninstall opencv-python opencv-contrib-python -y && \
    pip install --no-cache-dir opencv-contrib-python && \
    rm -rf /tmp/* && \
    rm -rf $HOME/.cache

# apex

USER root

RUN cd /tmp/ && \
    git clone --depth 1 https://github.com/NVIDIA/apex && \
    cd apex && \
    pip install -v --no-cache-dir \
     --global-option="--cpp_ext" --global-option="--cuda_ext" \
     . && \
    cd .. && rm -rf apex && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/* && \
    rm -rf /tmp/* && \
    rm -rf $HOME/.cache

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
    apt-get autoremove -y && \
    apt-get clean && \
    mkdir /tmp/openmpi && \
    cd /tmp/openmpi && \
    wget https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-4.0.1.tar.gz && \
    tar zxf openmpi-4.0.1.tar.gz && \
    cd openmpi-4.0.1 && \
    ./configure --enable-orterun-prefix-by-default && \
    make -j $(nproc) all && \
    make install && \
    ldconfig && \
    ldconfig /usr/local/cuda/targets/x86_64-linux/lib/stubs && \
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

