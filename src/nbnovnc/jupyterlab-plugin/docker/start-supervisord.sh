#!/usr/bin/env bash
main() {
    set -eux
    local -r JUPYTERLAB_DIR=$(jupyter lab path|sed -En 's/Application directory: *(.*)/\1/p')
    local -r PLUGIN_CONFIG="${JUPYTERLAB_DIR:-}/schemas/@tlkh/jupyterlab-vnc/plugin.json"
    if [[ -e "${PLUGIN_CONFIG:-}" && -n "${JUPYTERHUB_SERVICE_PREFIX:-}" ]]; then
        local -r VNC_URL="${JUPYTERHUB_SERVICE_PREFIX}/proxy/6080/vnc_lite.html?path=${JUPYTERHUB_SERVICE_PREFIX}/proxy/6080/"
        sudo sed -E -i.bak 's|"\$VNC_URL"|'"${VNC_URL}"'|g' "${PLUGIN_CONFIG}"
    fi
    sudo start-stop-daemon --start --quiet --startas /usr/bin/supervisord --pidfile /var/run/supervisord.pid -- -c /etc/supervisor/supervisord.conf
}

(main "$@") >/tmp/startup.log 2>&1
