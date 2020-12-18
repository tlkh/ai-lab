# renku-jupyterlab-vnc

A JupyterLab extension for VNC.

* This extension creates a menu, palette and a launcher for opening a VNC frame in a Jupyterlab tab. 
* This extension will not work as a standalone, it is meant to be used with jupyterlab.
* This extension does not provide a VNC server, which must be started independently.

The extension should be used with the Docker image built from [docker/Dockerfile](./docker/Dockerfile#L25), or equivalent.

## Prerequisites

* JupyterLab
* Jupyterlab nbserverproxy
* A web-based VNC server

## Installation

```bash
jupyter labextension install @tlkh/jupyterlab-vnc
```

See ./docker/Dockerfile for an example.

## TODO

This was quickly put together for a PoC and not meant to be production-ready.

It requires the minimal novnc, webproxy, openbox, x11vnc, xvfb combo in a docker container, but it should work with other VNC server and windows manager.

The VNC is started before Jupyterlab starts. It uses nbserverproxy to further proxy novnc's 6080 port through Jupyterlab's 8888, which requires some runtime adjustment to properly set the path parameter in the URL. This is currently done in the plugin's settings before starting jupyterlab, which could be better handled with a server extensions.

Opengl will not work with xvfb, you'll probably need xorg if that's what you want.

Ports numbers and screen resolution are hardcoded.

## Development

For a development environment (requires npm version 4 or later), do the following in the repository directory:

```bash
npm install
npm run build
jupyter labextension link .
```

To rebuild the package and the JupyterLab app:

```bash
npm run build
jupyter lab build
```

