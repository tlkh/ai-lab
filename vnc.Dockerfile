# nvidia/cuda
# https://hub.docker.com/r/nvidia/cuda
FROM nvaitc/ai-lab:0.7
#FROM nvaitc/ai-lab:latest

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
    HOME=/home/$NB_USER \
    TURBOVNC_VERSION=2.2.1 \
    VIRTUALGL_VERSION=2.5.2 \
    LIBJPEG_VERSION=1.5.2 \
    WEBSOCKIFY_VERSION=0.8.0 \
    NOVNC_VERSION=1.0.0 \
    LIBGLVND_VERSION=0.1.1

COPY xorg.conf.nvidia-headless /etc/X11/xorg.conf

RUN apt-get update && \
    apt-get install --no-upgrade -yq --no-install-recommends \
    git \
    ca-certificates \
    make \
    automake \
    autoconf \
    libtool \
    pkg-config \
    python \
    libxext-dev \
    libx11-dev \
    x11proto-gl-dev && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/*

WORKDIR /opt/

RUN git clone --depth 1 --branch="${LIBGLVND_VERSION}" https://github.com/NVIDIA/libglvnd.git && \
    cd libglvnd && ./autogen.sh && \
    ./configure --prefix=/usr/local --libdir=/usr/local/lib/x86_64-linux-gnu && \
    make -j install-strip && \
    find /usr/local/lib/x86_64-linux-gnu -type f -name 'lib*.la' -delete && \
    echo '/usr/local/lib/x86_64-linux-gnu' >> /etc/ld.so.conf.d/glvnd.conf && \
    echo '/usr/local/lib/i386-linux-gnu' >> /etc/ld.so.conf.d/glvnd.conf && \
    ldconfig && \
    rm -rf /opt/libglvnd && \
    rm -rf /home/$NB_USER/.cache && \
    fix-permissions /home/$NB_USER

ENV LD_LIBRARY_PATH /usr/local/lib/x86_64-linux-gnu:/usr/local/lib/i386-linux-gnu${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

RUN apt-get update && \
    apt-get install software-properties-common -yq && \
    add-apt-repository ppa:ubuntu-desktop/ubuntu-make -y && \
    apt-get update && \
    apt-get install --no-upgrade -yq \
    mesa-common-dev libgl1-mesa-dev freeglut3-dev libglu1-mesa-dev \
    libc6-dev libglu1 libsm6 libxv1 \
    novnc supervisor xinit ubuntu-make \
    xubuntu-desktop idle3 && \
    apt-get purge -yq \
    libreoffice* thunderbird* pidgin* \
    gnome* blueman* bluez* unity* cups* totem* \
    empathy* evolution* rhythmbox* shotwell* \
    account-plugin-* example-content* duplicity* \
    ttf-arabeyes ttf-arphic-uming ttf-indic-fonts-core \
    ttf-malayalam-fonts ttf-thai-tlwg ttf-unfonts-core \
    ppp* wvdial* transmission* \
    && \
    cd /tmp && \
    curl -fsSL -O https://svwh.dl.sourceforge.net/project/turbovnc/${TURBOVNC_VERSION}/turbovnc_${TURBOVNC_VERSION}_amd64.deb \
        -O https://svwh.dl.sourceforge.net/project/libjpeg-turbo/${LIBJPEG_VERSION}/libjpeg-turbo-official_${LIBJPEG_VERSION}_amd64.deb \
        -O https://svwh.dl.sourceforge.net/project/virtualgl/${VIRTUALGL_VERSION}/virtualgl_${VIRTUALGL_VERSION}_amd64.deb \
        -O https://svwh.dl.sourceforge.net/project/virtualgl/${VIRTUALGL_VERSION}/virtualgl32_${VIRTUALGL_VERSION}_amd64.deb && \
    dpkg -i *.deb && \
    rm -f /tmp/*.deb && \
    sed -i 's/$host:/unix:/g' /opt/TurboVNC/bin/vncserver && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/*

RUN /opt/VirtualGL/bin/vglserver_config -config +s +f +t

RUN cd /opt/ && \
    git clone --depth 1 https://github.com/novnc/noVNC && \
    cd noVNC/utils && git clone --depth 1 https://github.com/novnc/websockify websockify

RUN chmod 777 /opt/conda/lib/python3.6/site-packages/easy-install.pth

WORKDIR /home/$NB_USER

USER $NB_USER

RUN pip install --no-cache-dir \
    keras-rl pyopengl \
    gym[atari] ray[rllib] roboschool \
    jupyter-vscode-server==0.0.4 pysc2 \
    python-language-server[yapf] \
    setuptools wheel && \
    cd /home/$NB_USER && \
    git clone --depth 1 https://github.com/openai/spinningup.git && \
    cd spinningup && pip install --no-cache-dir -e . && \
    cd /home/$NB_USER && rm -rf spinningup \
    rm -rf /home/$NB_USER/.cache && \
    fix-permissions /home/$NB_USER

USER root

RUN cd /home/$NB_USER && \
    git clone --depth 1 https://github.com/novnc/websockify && \
    git clone --depth 1 https://github.com/tlkh/nbnovnc && \
    cd websockify && \
    python setup.py install && \
    cd /home/$NB_USER && \
    cd nbnovnc && \
    python setup.py sdist bdist_wheel && \
    cd dist && \
    pip install --no-cache-dir *.whl && \
    rm -rf /home/$NB_USER/.cache *.whl && \
    cd /home/$NB_USER && \
    rm -rf websockify nbnovnc && \
    fix-permissions /home/$NB_USER

USER $NB_USER

RUN jupyter serverextension enable  --py --sys-prefix nbnovnc && \
    jupyter nbextension     install --py --sys-prefix nbnovnc && \
    jupyter nbextension     enable  --py --sys-prefix nbnovnc && \
    rm -rf /home/$NB_USER/.cache && \
    fix-permissions /home/$NB_USER

USER root

ENV CODESERVER_URL="https://github.com/codercom/code-server/releases/download/1.691-vsc1.33.0/code-server1.691-vsc1.33.0-linux-x64.tar.gz" \
    CODESERVER="code-server1.691-vsc1.33.0-linux-x64"

RUN wget ${CODESERVER_URL} && \
    tar xvf ${CODESERVER}.tar.gz && \
    mv ${CODESERVER}/code-server /usr/local/bin/ && \
    rm -rf code-server* && \
    rm -rf /home/$NB_USER/.cache && \
    fix-permissions /home/$NB_USER

COPY Xvnc-session /etc/X11/

RUN chmod 777 /etc/X11/Xvnc-session

USER $NB_UID
