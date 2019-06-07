# Base image built from `base.Dockerfile`

FROM nvaitc/ai-lab:0.8-base

LABEL maintainer="Timothy Liu <timothyl@nvidia.com>"

USER root

ENV DEBIAN_FRONTEND noninteractive

# pytorch

USER $NB_UID

RUN conda install -c pytorch --quiet --yes \
      'python=3.6' \
      'numpy=1.16.1' \
      'pytorch' \
      'torchvision' \
      'cudatoolkit=10.0' && \
    conda install -c pytorch -c fastai --quiet --yes \
      'python=3.6' \
      'numpy=1.16.1' \
      'fastai' \
      'dataclasses' && \
    pip install --no-cache-dir torchtext pytorch-pretrained-bert && \
    conda clean -tipsy && \
    conda build purge-all && \
    rm -rf /tmp/* && \
    rm -rf $HOME/.cache && \
    rm -rf $HOME/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions $HOME

# apex

USER $NB_UID

RUN git clone --depth 1 https://github.com/NVIDIA/apex && \
    cd apex && \
    pip install -v --no-cache-dir \
     --global-option="--cpp_ext" --global-option="--cuda_ext" \
     . && \
    cd .. && rm -rf apex && \
    rm -rf /tmp/* && \
    rm -rf $HOME/.cache && \
    rm -rf $HOME/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions $HOME

# facet

USER root

RUN cd /opt/ && git clone --depth 1 https://github.com/PAIR-code/facets

USER $NB_UID

RUN cd /opt/facets/ && jupyter nbextension install facets-dist/ --sys-prefix && \
    export PYTHONPATH=$PYTHONPATH:/opt/facets/facets_overview/python/ && \
    npm cache clean --force && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf /tmp/* && \
    rm -rf $HOME/.cache && \
    rm -rf $HOME/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions $HOME

# nvtop

USER root

RUN cd $HOME && \
    git clone https://github.com/Syllo/nvtop.git && \
    mkdir -p nvtop/build && cd nvtop/build && \
    cmake .. -DNVML_RETRIEVE_HEADER_ONLINE=True && \
    make && make install && \
    cd .. && rm -rf nvtop && \
    rm -rf /tmp/* && \
    rm -rf $HOME/.cache && \
    rm -rf $HOME/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions $HOME

# RAPIDS

USER $NB_UID

RUN pip install --no-cache-dir \
      dask-xgboost xgboost dask_labextension && \
    conda install -c nvidia/label/cuda10.0 -c rapidsai/label/cuda10.0 \
      -c numba -c conda-forge -c defaults \
      'python=3.6' \
      'numpy=1.16.1' \
      'dask' \
      'cudf' \
      'cuml' \
      'cugraph' \
      'dask-cuda' \
      'dask-cudf' \
      'dask-cuml' \
      'nvstrings' && \
    jupyter labextension install dask-labextension && \
    conda clean -tipsy && \
    conda build purge-all && \
    npm cache clean --force && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf /tmp/* && \
    rm -rf $HOME/.cache && \
    rm -rf $HOME/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions $HOME

# install our own build of TensorFlow

USER $NB_UID

ENV TENSORFLOW_URL=https://s3-ap-southeast-1.amazonaws.com/nvaitc/tensorflow_gpu-1.13.1%2Bnv-cp36-cp36m-linux_x86_64.whl \
    TENSORFLOW_FILENAME=tensorflow_gpu-1.13.1+nv-cp36-cp36m-linux_x86_64.whl

RUN cd $HOME/ && \
    echo -c "Downloading ${TENSORFLOW_FILENAME} from ${TENSORFLOW_URL}" && \
    wget -O ${TENSORFLOW_FILENAME} ${TENSORFLOW_URL} && \
    pip install --no-cache-dir ${TENSORFLOW_FILENAME} && \
    pip install --no-cache-dir --ignore-installed PyYAML \
      jupyter-tensorboard \
      tensorflow_datasets \
      tensorflow-hub \
      tensorflow-probability \
      tensorflow-model-optimization \
      && \
    rm -rf $HOME/${TENSORFLOW_FILENAME} && \
    jupyter tensorboard enable --sys-prefix && \
    jupyter labextension install jupyterlab_tensorboard && \
    conda clean -tipsy && \
    conda build purge-all && \
    npm cache clean --force && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf /tmp/* && \
    rm -rf $HOME/.cache && \
    rm -rf $HOME/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions $HOME

# OpenMPI + Horovod

USER root

RUN mkdir /tmp/openmpi && \
    cd /tmp/openmpi && \
    wget https://www.open-mpi.org/software/ompi/v3.1/downloads/openmpi-3.1.2.tar.gz && \
    tar zxf openmpi-3.1.2.tar.gz && \
    cd openmpi-3.1.2 && \
    ./configure --enable-orterun-prefix-by-default && \
    make -j $(nproc) all && \
    make install && \
    ldconfig && \
    rm -rf /tmp/openmpi && \
    rm -rf /tmp/* && \
    rm -rf $HOME/.cache && \
    rm -rf $HOME/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions $HOME

RUN ldconfig /usr/local/cuda/targets/x86_64-linux/lib/stubs

ENV HOROVOD_GPU_ALLREDUCE=NCCL \
    HOROVOD_WITH_TENSORFLOW=1 \
    HOROVOD_WITH_PYTORCH=1

RUN pip install --no-cache-dir horovod && \
    rm -rf /tmp/* && \
    rm -rf $HOME/.cache && \
    rm -rf $HOME/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions $HOME

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

# autokeras

USER $NB_UID

RUN cd $HOME && \
    pip uninstall urllib3 -y && \
    git clone https://github.com/NVAITC/autokeras.git && \
    cd autokeras/ && python setup.py install && \
    cd .. && rm -rf autokeras && \
    pip uninstall requests urllib3 -y && \
    pip install requests urllib3 && \
    rm -rf /tmp/* && \
    rm -rf $HOME/.cache && \
    rm -rf $HOME/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions $HOME

# Switch back to jovyan to avoid accidental container runs as root

USER $NB_UID
