# pull optimised image from NGC
FROM nvcr.io/nvidia/tensorflow:19.03-py3

LABEL maintainer="Timothy Liu <timothyl@nvidia.com>"

USER root

ENV DEBIAN_FRONTEND noninteractive

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
    #texlive-fonts-extra \
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
    openssh-client \
    openssh-server \
    mecab \
    mecab-ipadic-utf8 \
    libmecab-dev \
    swig \
    protobuf-compiler \
    && curl -sL https://deb.nodesource.com/setup_11.x | bash - \
    && apt-get install -yq --no-install-recommends nodejs \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configure environment
ENV SHELL=/bin/bash \
    NB_USER=jovyan \
    NB_UID=1000 \
    NB_GID=100 \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8

ENV HOME=/home/$NB_USER

ADD fix-permissions /usr/local/bin/fix-permissions

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen && \
    groupadd wheel -g 11 && \
    echo "auth required pam_wheel.so use_uid" >> /etc/pam.d/su && \
    useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    chmod g+w /etc/passwd && \
    npm install -g configurable-http-proxy && \
    mkdir /usr/etc && \
    mkdir /home/$NB_USER/work && \
    fix-permissions /home/$NB_USER

RUN curl https://bootstrap.pypa.io/get-pip.py | python3

COPY requirements.txt /home/$NB_USER/

RUN pip3 uninstall jupyter-client jupyter-core jupyterlab jupyterlab-server notebook -y && \
    pip3 install --no-cache-dir jupyter notebook jupyterhub jupyterlab==1.0.0a1 jupyter_contrib_nbextensions ipywidgets && \
    pip3 install --no-cache-dir -r /home/$NB_USER/requirements.txt && \
    pip3 install --no-cache-dir jupyter-tensorboard && \
    pip3 uninstall torch pytorch-pretrained-bert -y && \
    npm cache clean --force && \
    rm -rf /home/$NB_USER/.node-gyp && \
    rm -rf /home/$NB_USER/.cache && \
    rm -Rf /home/$NB_USER/requirements.txt /home/$NB_USER/.pip

RUN jupyter notebook --generate-config

# Install Jupyter Notebook, Lab, and Hub
# Generate a notebook server config
# Cleanup temporary files
# Correct permissions
# Do all this in a single RUN command to avoid duplicating all of the
# files across image layers when the permissions change

# Activate ipywidgets extension in the environment that runs the notebook server

RUN jupyter nbextension enable --py widgetsnbextension --sys-prefix && \
    jupyter contrib nbextension install --sys-prefix && \
    # Also activate ipywidgets extension for JupyterLab
    jupyter labextension install @jupyter-widgets/jupyterlab-manager && \
    jupyter labextension install jupyterlab_bokeh && \
    jupyter tensorboard enable --sys-prefix && \
    npm cache clean --force && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    rm -rf /home/$NB_USER/.node-gyp && \
    fix-permissions /home/$NB_USER

# autokeras

RUN cd /home/$NB_USER && \
    git clone https://github.com/NVAITC/autokeras.git && \
    cd autokeras/ && python setup.py install && \
    cd .. && rm -rf autokeras && \
    rm -rf /home/$NB_USER/.cache && \
    fix-permissions /home/$NB_USER

USER root

# Import matplotlib the first time to build the font cache.
ENV XDG_CACHE_HOME /home/$NB_USER/.cache/
RUN MPLBACKEND=Agg python3 -c "import matplotlib.pyplot" && \
    fix-permissions /home/$NB_USER

EXPOSE 8888
EXPOSE 6006
WORKDIR $HOME

# Configure container startup
ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "-g", "--"]
CMD ["start-notebook.sh"]

# Add local files as late as possible to avoid cache busting
COPY start.sh /usr/local/bin/
COPY start-notebook.sh /usr/local/bin/
COPY start-singleuser.sh /usr/local/bin/
COPY jupyter_notebook_config.py /etc/jupyter/
RUN fix-permissions /etc/jupyter/
RUN chmod +x /usr/local/bin/*.sh

RUN usermod -s /bin/bash $NB_USER

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID