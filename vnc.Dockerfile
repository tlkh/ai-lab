# nvidia/cuda
# https://hub.docker.com/r/nvidia/cuda
#FROM nvaitc/ai-lab:0.7-test
FROM nvaitc/ai-lab:latest

LABEL maintainer="Timothy Liu <timothyl@nvidia.com>"

USER root

ENV DEBIAN_FRONTEND noninteractive

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

RUN apt-get update && \
    apt-get install --no-upgrade -yq \
    tigervnc-standalone-server tigervnc-xorg-extension tigervnc-viewer \
    novnc supervisor xinit \
    xubuntu-desktop \
    && \
    apt-get purge libreoffice* thunderbird* -y && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN cd /opt/ && \
    git clone https://github.com/novnc/noVNC && \
    cd noVNC/utils && git clone https://github.com/novnc/websockify websockify

RUN chmod -R 777 /opt/conda/lib/python3.6/site-packages/easy-install.pth \
     /opt/conda/lib/python3.6/site-packages/setuptools.pth

USER root

RUN pip install --no-cache-dir setuptools wheel && \
    cd /home/$NB_USER && \
    git clone https://github.com/novnc/websockify && \
    cd websockify && \
    python setup.py install && \
    cd /home/$NB_USER && \
    git clone https://github.com/tlkh/nbnovnc && \
    cd nbnovnc && \
    python setup.py sdist bdist_wheel && \
    cd dist && \
    pip install *.whl && \
    jupyter serverextension enable  --py --sys-prefix nbnovnc && \
    jupyter nbextension     install --py --sys-prefix nbnovnc && \
    jupyter nbextension     enable  --py --sys-prefix nbnovnc

COPY Xvnc-session /etc/X11/

RUN chmod 777 /etc/X11/Xvnc-session

USER $NB_USER
