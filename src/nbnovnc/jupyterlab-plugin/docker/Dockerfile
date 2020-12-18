FROM renku/singleuser:0.3.2

RUN    sudo apt update \
    && sudo DEBIAN_FRONTEND=noninteractive apt install -y \
            ca-certificates \
            openssl \
            xvfb \
            x11vnc \
            openbox \
            supervisor \
    && sudo apt autoremove --purge \
    && sudo apt clean \
    && sudo rm -rf /var/lib/apt/lists/* \
    && sudo rm -rf /tmp/* \
    && sudo find /var/log -type f -exec cp /dev/null \{\} \;

RUN    sudo git clone https://github.com/novnc/noVNC.git /opt/novnc \
    && sudo git clone https://github.com/novnc/websockify.git /opt/novnc/utils/websockify \
    && sudo rm -rf /opt/novnc/.git \
    && sudo rm -rf /opt/novnc/utils/websockify.git \
    && sudo rm -rf /tmp/*

RUN    pip install nbserverproxy \
    && jupyter serverextension enable --py nbserverproxy \
    && jupyter labextension install @tlkh/jupyterlab-vnc

ENV DISPLAY :1

COPY --chown=root:root desktop.conf /etc/supervisor/conf.d/
COPY --chown=root:root start-supervisord.sh /usr/local/bin/start-notebook.d/start-supervisord.sh

EXPOSE 8888

# Uncomment to install the python dependencies
# COPY requirements.txt /tmp/requirements.txt
# RUN pip install -r /tmp/requirements.txt \
#     && rm -f /tmp/requirements.txt

ENTRYPOINT [ "tini", "-g", "--", "/usr/local/bin/start.sh" ]
