# Base image built from `tf.Dockerfile`

FROM nvaitc/ai-lab:20.01-tf2

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
      'cudatoolkit=10.1' && \
    pip install --no-cache-dir torchtext && \
    conda install -c pytorch -c fastai --quiet --yes \
      'python=3.6' \
      'numpy=1.16.1' \
      'fastai' \
      'dataclasses' && \
    pip uninstall pillow -y && \
      CC="cc -mavx2" pip install -U --force-reinstall --no-cache-dir pillow-simd && \
    conda clean -tipsy && \
    conda build purge-all && \
    find $CONDA_DIR -type f,l -name '*.a' -delete && \
    find $CONDA_DIR -type f,l -name '*.pyc' -delete && \
    find $CONDA_DIR -type f,l -name '*.js.map' -delete && \
    rm -rf $CONDA_DIR/pkgs && \
    rm -rf /tmp/* && \
    rm -rf $HOME/.cache && \
    rm -rf $HOME/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions $HOME

# apex

USER root

RUN apt-get update && \
    apt-get install -yq --no-upgrade \
    cuda-nvml-dev-$CUDA_PKG_VERSION \
    cuda-command-line-tools-$CUDA_PKG_VERSION \
    cuda-libraries-dev-$CUDA_PKG_VERSION \
    cuda-minimal-build-$CUDA_PKG_VERSION \
    libnccl-dev=$NCCL_VERSION-1+cuda10.1 && \
    cd /tmp/ && \
    git clone --depth 1 https://github.com/NVIDIA/apex && \
    cd apex && \
    pip install -v --no-cache-dir \
     --global-option="--cpp_ext" --global-option="--cuda_ext" \
     . && \
    cd .. && rm -rf apex && \
    apt-get remove -yq \
      cuda-nvml-dev-$CUDA_PKG_VERSION \
      cuda-command-line-tools-$CUDA_PKG_VERSION \
      cuda-libraries-dev-$CUDA_PKG_VERSION \
      libnccl-dev=$NCCL_VERSION-1+cuda10.1 && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/* && \
    rm -rf /tmp/* && \
    rm -rf $HOME/.cache && \
    rm -rf $HOME/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions $HOME

# RAPIDS

USER $NB_UID

RUN conda install \
      -c nvidia/label/cuda10.1 \
      -c rapidsai/label/cuda10.1 \
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
    conda install \
      -c rapidsai/label/xgboost \
      'xgboost' \
      'dask-xgboost' && \
    pip install --no-cache-dir \
      dask_labextension && \
    jupyter labextension install dask-labextension && jupyter lab clean && \
    conda clean -tipsy && \
    conda build purge-all && \
    find $CONDA_DIR -type f,l -name '*.a' -delete && \
    find $CONDA_DIR -type f,l -name '*.pyc' -delete && \
    find $CONDA_DIR -type f,l -name '*.js.map' -delete && \
    rm -rf $CONDA_DIR/pkgs && \
    npm cache clean --force && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf /tmp/* && \
    rm -rf $HOME/.cache && \
    rm -rf $HOME/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions $HOME

ENV HOROVOD_GPU_ALLREDUCE=NCCL \
    HOROVOD_WITH_TENSORFLOW=1 \
    HOROVOD_WITH_PYTORCH=1

USER root

RUN apt-get update && \
    apt-get install -yq --no-upgrade \
      cuda-nvml-dev-$CUDA_PKG_VERSION \
      cuda-command-line-tools-$CUDA_PKG_VERSION \
      cuda-libraries-dev-$CUDA_PKG_VERSION \
      cuda-minimal-build-$CUDA_PKG_VERSION \
      libnccl-dev=$NCCL_VERSION-1+cuda10.1 && \
    pip install --no-cache-dir horovod && \
    apt-get remove -yq \
      cuda-nvml-dev-$CUDA_PKG_VERSION \
      cuda-command-line-tools-$CUDA_PKG_VERSION \
      cuda-libraries-dev-$CUDA_PKG_VERSION \
      libnccl-dev=$NCCL_VERSION-1+cuda10.1 && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/* && \
    rm -rf /tmp/* && \
    rm -rf $HOME/.cache && \
    rm -rf $HOME/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions $HOME

# Switch back to jovyan to avoid accidental container runs as root

USER $NB_UID

