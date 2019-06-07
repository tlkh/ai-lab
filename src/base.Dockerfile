# Base image:
# https://hub.docker.com/r/nvidia/cuda
# Build this Dockerfile and tag as:
# nvaitc/ai-lab:x.x-base

FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04 

LABEL maintainer="Timothy Liu <timothyl@nvidia.com>"

USER root

ENV DEBIAN_FRONTEND noninteractive

# Install all OS dependencies

COPY sources.list /etc/apt/

RUN apt-get update && \
    apt-get install -yq --no-install-recommends --no-upgrade \
    apt-utils && \
    apt-get install -yq --no-install-recommends --no-upgrade \
    curl \
    wget \
    bzip2 \
    ca-certificates \
    locales \
    fonts-liberation \
    build-essential \
    cmake \
    jed \
    libsm6 \
    libxext-dev \
    libxrender1 \
    lmodern \
    netcat \
    pandoc \
    texlive-fonts-recommended \
    texlive-generic-recommended \
    texlive-latex-base \
    texlive-latex-extra \
    texlive-xetex \
    ffmpeg \
    graphviz\
    git \
    nano \
    htop \
    zip \
    unzip \
    libncurses5-dev \
    libncursesw5-dev \
    libopenmpi-dev \
    libopenblas-base \
    libopenblas-dev \
    libomp-dev \
    libjpeg-dev \
    libpng-dev \
    libboost-all-dev \
    libsdl2-dev \
    openssh-client \
    openssh-server \
    swig \
    pkg-config \
    g++ \
    zlib1g-dev \
    protobuf-compiler \
    libosmesa6-dev \
    patchelf \
    xvfb \
    zsh \
    sudo \
    && apt-get clean && \
    rm -rf /tmp/* && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# Configure environment

ENV CONDA_DIR=/opt/conda \
    SHELL=/bin/bash \
    NB_USER=jovyan \
    NB_UID=1000 \
    NB_GID=100 \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8

ENV PATH=$CONDA_DIR/bin:$PATH \
    HOME=/home/$NB_USER

# script used to restore permissions after each step as root

ADD fix-permissions /usr/local/bin/fix-permissions

# Create jovyan user with UID=1000 and in the 'users' group
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

ENV MINICONDA_VERSION 4.6.14

WORKDIR $HOME

ADD requirements.txt requirements.txt

RUN wget --quiet https://repo.continuum.io/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
    /bin/bash Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
    rm Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
    $CONDA_DIR/bin/conda config --system --prepend channels conda-forge && \
    $CONDA_DIR/bin/conda config --system --set auto_update_conda false && \
    $CONDA_DIR/bin/conda config --system --set show_channel_urls true && \
    $CONDA_DIR/bin/conda install --quiet --yes conda="${MINICONDA_VERSION%.*}.*" && \
    $CONDA_DIR/bin/conda update --all --quiet --yes && \
    echo "Installing packages" && \
    conda install -n root conda-build && \
    conda install -c nvidia -c numba -c pytorch -c conda-forge -c rapidsai -c defaults  --quiet --yes \
      'python=3.6' \
      'numpy=1.16.1' \
      'cudatoolkit=10.0' \
      'tk' \
      'tini' \
      'blas=*=openblas' \
      'notebook=5.7.*' \
      'jupyterhub=1.0.*' \
      'jupyterlab=0.35.*' \
      'jupyter_contrib_nbextensions' \
      'ipywidgets=7.4.*' && \
    pip install --no-cache-dir -r $HOME/requirements.txt && \
    rm $HOME/requirements.txt && \
    pip uninstall opencv-python -y && \
    pip install --no-cache-dir opencv-contrib-python && \
    pip uninstall pillow -y && \
      CC="cc -mavx2" pip install -U --force-reinstall --no-cache-dir pillow-simd && \
    jupyter notebook --generate-config && \
    jupyter nbextension enable --py widgetsnbextension --sys-prefix && \
    jupyter contrib nbextension install --sys-prefix && \
    jupyter labextension install @jupyter-widgets/jupyterlab-manager && \
    jupyter labextension install jupyterlab-server-proxy && \
    jupyter labextension install @jupyterlab/hub-extension && \
    conda list tini | grep tini | tr -s ' ' | cut -d ' ' -f 1,2 >> $CONDA_DIR/conda-meta/pinned && \
    conda clean -tipsy && \
    conda build purge-all && \
    npm cache clean --force && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf /tmp/* && \
    rm -rf $HOME/.cache && \
    rm -rf $HOME/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions $HOME

EXPOSE 8888

WORKDIR $HOME

# Configure container startup

ENTRYPOINT ["tini", "-g", "--"]
CMD ["start-notebook.sh"]

# Add local files as late as possible to avoid cache busting

COPY user_setup /opt/user_setup
ENV USER_SETUP /opt/user_setup/setup.sh

COPY start.sh /usr/local/bin/
COPY start-notebook.sh /usr/local/bin/
COPY start-singleuser.sh /usr/local/bin/
COPY jupyter_notebook_config.py /etc/jupyter/

RUN fix-permissions /etc/jupyter/ && \
    usermod -s /bin/bash $NB_USER

USER root

ENV NB_PASSWD="" \
    SUDO_PASSWD=jovyan

RUN echo "${SUDO_PASSWD}\n${SUDO_PASSWD}\n" | (passwd jovyan)

# Switch back to jovyan to avoid accidental container runs as root

USER $NB_UID
