# nvidia/cuda
# https://hub.docker.com/r/nvidia/cuda
FROM nvidia/cuda:9.2-cudnn7-devel-ubuntu18.04 

LABEL maintainer="Timothy Liu <timothyl@nvidia.com>"

USER root

ENV DEBIAN_FRONTEND noninteractive

# Install all OS dependencies for notebook server

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
    inkscape \
    jed \
    libsm6 \
    libxext-dev \
    libxrender1 \
    lmodern \
    netcat \
    pandoc \
    texlive-fonts-extra \
    texlive-fonts-recommended \
    texlive-generic-recommended \
    texlive-latex-base \
    texlive-latex-extra \
    texlive-xetex \
    ffmpeg \
    graphviz\
    zlib1g-dev  \
    lib32z1-dev \
    git \
    emacs \
    vim \
    nano \
    zip \
    unzip \
    htop \
    libopenmpi-dev \
    libjpeg-dev \
    libpng-dev \
    openssh-client \
    openssh-server \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

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

RUN groupadd wheel -g 11 && \
    echo "auth required pam_wheel.so use_uid" >> /etc/pam.d/su && \
    useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    mkdir -p $CONDA_DIR && \
    chown $NB_USER:$NB_GID $CONDA_DIR && \
    chmod g+w /etc/passwd && \
    fix-permissions $HOME && \
    fix-permissions $CONDA_DIR

USER $NB_UID

RUN fix-permissions /home/$NB_USER

# Install conda as jovyan

ENV MINICONDA_VERSION 4.5.11

RUN cd /tmp && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
    /bin/bash Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
    rm Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
    $CONDA_DIR/bin/conda config --system --prepend channels conda-forge && \
    $CONDA_DIR/bin/conda config --system --set auto_update_conda false && \
    $CONDA_DIR/bin/conda config --system --set show_channel_urls true && \
    $CONDA_DIR/bin/conda install --quiet --yes conda="${MINICONDA_VERSION%.*}.*" && \
    $CONDA_DIR/bin/conda update --all --quiet --yes && \
    echo 'chained install: general dependencies' && \
    conda install -c nvidia -c numba -c pytorch -c conda-forge -c rapidsai -c defaults  --quiet --yes \
    'intake' \
    'cudatoolkit' \
    'pytest' \
    'numba>=0.41.0dev' \
    'pandas=0.20.3' \
    'pyarrow=0.10.0' \
    'cmake>=3.12' \
    'bokeh' \
    'boost' \
    'nvstrings' \
    'zlib' \
    'libgdf_cffi' \
    'cffi>=1.10.0' \
    'distributed>=1.23.0' \
    'faiss-gpu' \
    'blas=*=openblas' \
    'cython>=0.29' && \
    conda clean -tipsy && \
    rm -rf /home/$NB_USER/.cache && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# if you don't run this you could get:
# BlockingIOError(11, 'write could not complete without blocking', 69632)
RUN python -c 'import os,sys,fcntl; flags = fcntl.fcntl(sys.stdout, fcntl.F_GETFL); fcntl.fcntl(sys.stdout, fcntl.F_SETFL, flags&~os.O_NONBLOCK);'

# Install Jupyter Notebook, Lab, and Hub

RUN conda install -c conda-forge --quiet --yes \
    'notebook=5.7.*' \
    'jupyterhub=0.9.*' \
    'jupyterlab=0.35.*' \
    'jupyter_contrib_nbextensions' \
    'ipywidgets=7.2*' && \
    jupyter notebook --generate-config && \
    # Activate ipywidgets extension in the environment that runs the notebook server
    jupyter nbextension enable --py widgetsnbextension --sys-prefix && \
    jupyter contrib nbextension install --sys-prefix && \
    # Also activate ipywidgets extension for JupyterLab
    jupyter labextension install @jupyter-widgets/jupyterlab-manager && \
    jupyter labextension install jupyterlab_bokeh && \
    jupyter labextension install @jupyterlab/hub-extension && \
    echo "chained conda install: tini" && \
    conda install --quiet --yes 'tini=0.18.0' && \
    conda list tini | grep tini | tr -s ' ' | cut -d ' ' -f 1,2 >> $CONDA_DIR/conda-meta/pinned && \
    conda clean -tipsy && \
    npm cache clean --force && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf /home/$NB_USER/.cache && \
    rm -rf /home/$NB_USER/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

RUN git config --global core.editor "nano"

# deep learning and misc pip packages

COPY requirements.txt /home/$NB_USER/

RUN conda install -c pytorch pytorch torchvision --quiet --yes && \
    conda install -c anaconda tensorflow-gpu=1.11 --quiet --yes && \
    pip install --ignore-installed --no-cache-dir 'pyyaml>=4.2b4' && \
    pip install --ignore-installed --no-cache-dir 'msgpack>=0.6.0' && \
    pip install --no-cache-dir -r /home/$NB_USER/requirements.txt && \
    pip uninstall pillow -y && \
    CC="cc -mavx2" pip install -U --force-reinstall --no-cache-dir pillow-simd && \
    rm /home/$NB_USER/requirements.txt && \
    pip install --no-cache-dir jupyterlab_github jupyter-tensorboard && \
    jupyter tensorboard enable --sys-prefix && \
    jupyter serverextension enable --sys-prefix jupyterlab_github && \
    jupyter labextension install @jupyterlab/github && \
    echo "Installing fastai library" && \
    conda install -c pytorch -c fastai fastai dataclasses && \
    conda clean -tipsy && \
    npm cache clean --force && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf /home/$NB_USER/.cache && \
    rm -rf /home/$NB_USER/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER
    
# extras

# RAPIDS

USER root

ENV CUDACXX /usr/local/cuda/bin/nvcc

RUN ln -s /usr/local/cuda/lib64/stubs/libcuda.so /usr/local/cuda/lib64/stubs/libcuda.so.1 && \
    export LD_LIBRARY_PATH=/usr/local/cuda/lib64/stubs/:$LD_LIBRARY_PATH && \
    ldconfig && \
    cd /home/$NB_USER/ && \
    git clone --recursive https://github.com/NVAITC/build-rapids && \
    cd ./build-rapids/ && bash ./build-rapids.sh && \
    cd .. && rm -rf ./build-rapids && \
    rm -rf /home/$NB_USER/.cache && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# OpenMPI + Horovod

RUN mkdir /tmp/openmpi && \
    cd /tmp/openmpi && \
    wget https://www.open-mpi.org/software/ompi/v3.1/downloads/openmpi-3.1.2.tar.gz && \
    tar zxf openmpi-3.1.2.tar.gz && \
    cd openmpi-3.1.2 && \
    ./configure --enable-orterun-prefix-by-default && \
    make -j $(nproc) all && \
    make install && \
    ldconfig && \
    rm -rf /tmp/openmpi

RUN ldconfig /usr/local/cuda/targets/x86_64-linux/lib/stubs
    
USER $NB_UID
    
RUN HOROVOD_GPU_ALLREDUCE=NCCL HOROVOD_WITH_TENSORFLOW=1 HOROVOD_WITH_PYTORCH=1 \
    pip install --no-cache-dir horovod && \
    rm -rf /home/$NB_USER/.cache && \
    fix-permissions /home/$NB_USER

USER root

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

USER $NB_UID

# autokeras

RUN cd /home/$NB_USER && \
    git clone https://github.com/NVAITC/autokeras.git && \
    cd autokeras/ && python setup.py install && \
    cd .. && rm -rf autokeras/ && \
    rm -rf /home/$NB_USER/.cache && \
    fix-permissions /home/$NB_USER

# flair

RUN cd /home/$NB_USER && \
    git clone https://github.com/NVAITC/flair.git && \
    cd flair/ && python setup.py install && \
    cd .. && rm -rf flair/ && \
    rm -rf /home/$NB_USER/.cache && \
    fix-permissions /home/$NB_USER

# Import matplotlib the first time to build the font cache

USER root

ENV XDG_CACHE_HOME /home/$NB_USER/.cache/

RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot" && \
    fix-permissions /home/$NB_USER

# end extras

EXPOSE 8888
EXPOSE 8787
EXPOSE 8786
EXPOSE 6006

WORKDIR $HOME

# Configure container startup

ENTRYPOINT ["tini", "-g", "--"]
CMD ["start-notebook.sh"]

# Add local files as late as possible to avoid cache busting

COPY start.sh /usr/local/bin/
COPY start-notebook.sh /usr/local/bin/
COPY start-singleuser.sh /usr/local/bin/
COPY jupyter_notebook_config.py /etc/jupyter/
RUN fix-permissions /etc/jupyter/

RUN usermod -s /bin/bash $NB_USER

# Switch back to jovyan to avoid accidental container runs as root

USER $NB_UID
