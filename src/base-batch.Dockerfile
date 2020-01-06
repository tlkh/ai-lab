# Base image:
# https://hub.docker.com/r/nvidia/cuda
# Build this Dockerfile and tag as:
# nvaitc/ai-lab:x.x-batch-base

FROM nvidia/cuda:10.1-cudnn7-runtime-ubuntu18.04 

LABEL maintainer="Timothy Liu <timothyl@nvidia.com>"

USER root

ENV DEBIAN_FRONTEND=noninteractive

# Install all OS dependencies

RUN apt-get update && \
    apt-get install -yq --no-install-recommends --no-upgrade \
    apt-utils && \
    apt-get install -yq --no-install-recommends --no-upgrade \
    curl \
    wget \
    bzip2 \
    ca-certificates \
    locales \
    build-essential \
    cmake \
    jed \
    libsm6 \
    libxext-dev \
    libxrender1 \
    lmodern \
    netcat \
    libjpeg-dev \
    libpng-dev  \
    ffmpeg \
    graphviz\
    git \
    nano \
    htop \
    zip \
    unzip \
    libncurses5-dev \
    libncursesw5-dev \
    libopenblas-base \
    libopenblas-dev \
    libboost-all-dev \
    libsdl2-dev \
    swig \
    pkg-config \
    g++ \
    zlib1g-dev \
    patchelf \
    sudo \
    && apt-get purge jed -y \
    && apt-get autoremove -y \
    && apt-get clean && \
    rm -rf /tmp/* && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# Configure environment

ENV CONDA_DIR=/opt/conda \
    SHELL=/bin/bash \
    NB_USER=user \
    NB_UID=1000 \
    NB_GID=100 \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8

ENV PATH=$CONDA_DIR/bin:$PATH \
    HOME=/home/$NB_USER

# script used to restore permissions after each step as root

ADD fix-permissions /usr/local/bin/fix-permissions

# Create user user with UID=1000 and in the 'users' group
# and make sure these dirs are writable by the `users` group.

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen && \  
    groupadd wheel -g 11 && \
    echo "auth sufficient pam_wheel.so use_uid" >> /etc/pam.d/su && \
    useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    usermod -aG sudo $NB_USER && \
    mkdir -p $CONDA_DIR && \
    chown $NB_USER:$NB_GID $CONDA_DIR && \
    chmod g+w /etc/passwd && \
    rm -rf /tmp/* && \
    fix-permissions $HOME && \
    fix-permissions $CONDA_DIR

USER $NB_UID

RUN fix-permissions $HOME

# base Python + PyData + PyTorch

ENV MINICONDA_VERSION 4.7.12.1

WORKDIR $HOME

ADD requirements.txt requirements.txt

RUN cd /tmp/ && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
    /bin/bash Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
    rm Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
    $CONDA_DIR/bin/conda config --system --prepend channels conda-forge && \
    $CONDA_DIR/bin/conda config --system --set auto_update_conda false && \
    $CONDA_DIR/bin/conda config --system --set show_channel_urls true && \
    $CONDA_DIR/bin/conda update --all --quiet --yes && \
    echo "Installing packages" && \
    conda install -n root conda-build=3.18.* && \
    pip install --no-cache-dir setuptools -U && \
    conda install --quiet --yes \
      -c nvidia -c numba -c pytorch -c conda-forge -c rapidsai -c defaults \
      'python=3.6' \
      'numpy=1.16.1' \
      'pandas' \
      'cudatoolkit=10.1' \
      'pytorch' \
      'torchvision' \
      'tk' \
      'tini' \
      'blas=*=openblas' && \
    pip install --no-cache-dir -r $HOME/requirements.txt && \
    rm $HOME/requirements.txt && \
    cd /tmp/ && \
    git clone --depth 1 https://github.com/huggingface/transformers && \
    cd /tmp/transformers && \
    pip install . && \
    cd $HOME && \
    pip uninstall opencv-python opencv-contrib-python -y && \
    pip install --no-cache-dir opencv-contrib-python && \
    pip uninstall pillow -y && \
      CC="cc -mavx2" pip install -U --force-reinstall --no-cache-dir pillow-simd && \
    conda list tini | grep tini | tr -s ' ' | cut -d ' ' -f 1,2 >> $CONDA_DIR/conda-meta/pinned && \
    conda clean -tipsy && \
    conda build purge-all && \
    find $CONDA_DIR -type f,l -name '*.a' -delete && \
    find $CONDA_DIR -type f,l -name '*.pyc' -delete && \
    find $CONDA_DIR -type f,l -name '*.js.map' -delete && \
    find $CONDA_DIR/lib/python*/site-packages/bokeh/server/static -type f,l -name '*.js' -not -name '*.min.js' -delete && \
    rm -rf $CONDA_DIR/pkgs && \
    cd /tmp/ && \
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

WORKDIR $HOME

# Configure container startup

ENTRYPOINT ["bash"]

COPY README.txt /home/$NB_USER/

RUN usermod -s /bin/bash $NB_USER

USER root

ENV SUDO_PASSWD=volta

RUN mkdir /results/ && \
    chmod -R 777 /results/ && \
    chmod -R 777 /home/$NB_USER/ && \
    echo "${SUDO_PASSWD}\n${SUDO_PASSWD}\n" | (passwd $NB_USER)

# Switch back to user to avoid accidental container runs as root

USER $NB_UID
