# builds the extended container
# with VNC and VS Code dev environments

FROM tlkh/ai-lab:20.12

LABEL maintainer="Timothy Liu <timothy_liu@mymail.sutd.edu.sg>"

ENV NVIDIA_DRIVER_CAPABILITIES ${NVIDIA_DRIVER_CAPABILITIES},display

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
    TURBOVNC_VERSION=2.2.5 \
    VIRTUALGL_VERSION=2.6.4 \
    LIBJPEG_VERSION=2.0.6 \
    WEBSOCKIFY_VERSION=0.9.0 \
    LIBGLVND_VERSION=master

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
    libc6-dev \
    libglu1 \
    libsm6 \
    libxv1 \
    x11-xkb-utils \
    xauth \
    xfonts-base \
    xkb-data \
    x11proto-gl-dev \
    # install Nsight profiling tools 
    libqt5x11extras5 \
    openjdk-8-jre \
    cuda-visual-tools-10-1 \
    cuda-nsight-systems-10-1 \
    cuda-nsight-compute-10-1 \
    cuda-cupti-10-1 \
    cuda-nvprof-10-1 && \
    # set JRE 8 as default
    echo 2 | update-alternatives --config java && \
    apt-get autoremove -y && \
    apt-get clean && \
    cd && \
    rm -rf /tmp/* && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# to double check
ENV PATH /opt/nvidia/nsight-compute:{${PATH}

WORKDIR /opt/

RUN cd /opt/ && \
    git clone --depth 1 --branch="${LIBGLVND_VERSION}" https://github.com/NVIDIA/libglvnd.git && \
    cd libglvnd && ./autogen.sh && \
    ./configure --prefix=/usr/local --libdir=/usr/local/lib/x86_64-linux-gnu && \
    make -j install-strip && \
    find /usr/local/lib/x86_64-linux-gnu -type f -name 'lib*.la' -delete && \
    echo '/usr/local/lib/x86_64-linux-gnu' >> /etc/ld.so.conf.d/glvnd.conf && \
    ldconfig && \
    rm -rf /opt/libglvnd && \
    rm -rf /tmp/* && \
    rm -rf $HOME/.cache && \
    rm -rf $HOME/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions $HOME

COPY 10_nvidia.json /usr/local/share/glvnd/egl_vendor.d/10_nvidia.json

ENV LD_LIBRARY_PATH /usr/local/lib/x86_64-linux-gnu:/usr/local/lib/i386-linux-gnu${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

RUN apt-get update && \
    apt-get install software-properties-common -yq && \
    add-apt-repository ppa:ubuntu-desktop/ubuntu-make -y && \
    apt-get update && \
    apt-get install --no-upgrade -yq \
    xvfb libosmesa6-dev mesa-utils libgles2-mesa \
    mesa-common-dev libgl1-mesa-dev freeglut3-dev libglu1-mesa-dev \
    novnc supervisor xinit ubuntu-make \
    xubuntu-desktop idle3 && \
    apt-get purge -yq \
    libreoffice* thunderbird* pidgin* sgt-puzzles* xscreensaver \
    gnome* blueman* bluez* unity* cups* totem* xfce4-dict* \
    empathy* evolution* rhythmbox* shotwell* xfburn* \
    account-plugin-* example-content* duplicity* \
    ttf-arabeyes ttf-arphic-uming ttf-indic-fonts-core \
    ttf-malayalam-fonts ttf-thai-tlwg ttf-unfonts-core \
    ppp* wvdial* transmission* \
    && \
    curl -fsSL -O https://udomain.dl.sourceforge.net/project/turbovnc/${TURBOVNC_VERSION}/turbovnc_${TURBOVNC_VERSION}_amd64.deb \
        -O https://udomain.dl.sourceforge.net/project/libjpeg-turbo/${LIBJPEG_VERSION}/libjpeg-turbo-official_${LIBJPEG_VERSION}_amd64.deb \
        -O https://udomain.dl.sourceforge.net/project/virtualgl/${VIRTUALGL_VERSION}/virtualgl_${VIRTUALGL_VERSION}_amd64.deb && \
    dpkg -i *.deb && \
    sed -i 's/$host:/unix:/g' /opt/TurboVNC/bin/vncserver && \
    apt-get autoremove -y && \
    apt-get clean && \
    cd && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/* && \
    rm -rf /tmp/* && \
    rm -rf $HOME/.cache && \
    rm -rf $HOME/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions $HOME

RUN /opt/VirtualGL/bin/vglserver_config -config +s +f +t

RUN cd /opt/ && \
    git clone --depth 1 https://github.com/novnc/noVNC && \
    cd noVNC/utils && git clone --depth 1 https://github.com/novnc/websockify websockify

WORKDIR /home/$NB_USER

USER $NB_USER

RUN pip install --no-cache-dir \
    pyopengl gym[atari] \
    jupyter-vscode-server jedi pysc2 \
    python-language-server[yapf] && \
    pip uninstall opencv-python opencv-python-headless opencv-contrib-python -y && \
    pip install --no-cache-dir opencv-contrib-python -U && \ 
    cd /tmp/ && \
    git clone --depth 1 https://github.com/tlkh/keras-rl2.git && \
    cd keras-rl2 && \
    pip install --no-cache-dir . && \
    rm -rf /tmp/* && cd && \
    rm -rf $HOME/.cache && \
    rm -rf $HOME/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions $HOME

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
    rm -rf /tmp/* && \
    rm -rf $HOME/.cache && \
    rm -rf $HOME/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions $HOME

USER $NB_USER

RUN jupyter serverextension enable  --py --sys-prefix nbnovnc && \
    jupyter nbextension     install --py --sys-prefix nbnovnc && \
    jupyter nbextension     enable  --py --sys-prefix nbnovnc && \
    rm -rf /tmp/* && \
    rm -rf $HOME/.cache && \
    rm -rf $HOME/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions $HOME

USER root

ENV CODESERVER_URL="https://github.com/cdr/code-server/releases/download/1.1156-vsc1.33.1/code-server1.1156-vsc1.33.1-linux-x64.tar.gz" \
    CODESERVER="code-server1.1156-vsc1.33.1-linux-x64"

RUN wget ${CODESERVER_URL} && \
    tar xvf ${CODESERVER}.tar.gz && \
    mv ${CODESERVER}/code-server /usr/local/bin/ && \
    rm -rf code-server* && \
    rm -rf /tmp/* && \
    rm -rf $HOME/.cache && \
    rm -rf $HOME/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions $HOME

COPY Xvnc-session /etc/X11/

RUN chmod 777 /etc/X11/Xvnc-session

USER $NB_UID

COPY nbnovnc /opt/nbnovnc

RUN cd /opt/ && \
    pip install --no-cache-dir jupyter jupyterlab --upgrade && \
    git clone --depth 1 https://github.com/novnc/websockify && \
    git clone --depth 1 https://github.com/jupyterhub/jupyter-server-proxy && \
    cd /opt/jupyter-server-proxy && \
    pip install --no-cache-dir -e . && \
    jupyter serverextension enable --sys-prefix jupyter_server_proxy && \
    jupyter labextension install @jupyterlab/server-proxy && \
    cd /opt/websockify && \
    python setup.py install && \
    cd /opt/nbnovnc && \
    pip install --no-cache-dir . && \
    cd /opt/nbnovnc/jupyterlab-plugin && \
    npm install && \
    npm run build && \
    jupyter labextension link . && \
    jupyter lab build && \
    cd /opt/ && \
    rm -rf /opt/.cache *.whl && \
    rm -rf websockify && \
    rm -rf /tmp/* && \
    rm -rf $HOME/.cache && \
    rm -rf $HOME/.node-gyp

RUN jupyter serverextension enable  --py --sys-prefix nbnovnc && \
    jupyter nbextension     install --py --sys-prefix nbnovnc && \
    jupyter nbextension     enable  --py --sys-prefix nbnovnc && \
    jupyter serverextension enable jupyterlab

ENV JUPYTER_ENABLE_LAB=yes
