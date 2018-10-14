# Deep Learning Lab

[![](https://images.microbadger.com/badges/image/tlkh/deeplearning-lab.svg)](https://microbadger.com/images/tlkh/deeplearning-lab "Get your own image badge on microbadger.com") [![](https://img.shields.io/github/issues/tlkh/deeplearning-lab.svg)](Issues) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

All-in-one Deep Learning Docker image compatible with JupyterHub and nvidia-docker container runtime

## What's Included

* CUDA 9.0 (Ubuntu 16.04 base)
* Text editors (like `nano`/`vim`) and utlities like `git`
* Python data science packages
  * `pandas`, `numpy`, `numba`, `sympy`, `scipy` etc.
  * `matplotlib` is pre-cached
  * Extras also included: `nltk`, `gensim`, `opencv`, `scikit-learn`
* `tensorflow-gpu` and `keras`
* `theano` without GPU support
* `pytorch` and `torchvision`, `torchtext`
* Jupyter Notebook and JupyterLab
  * including `ipywidgets` and `jupyter_contrib_nbextensions`

This image is can be used standalone or via JupyterHub.

## Using this image

```
# interactive shell
docker run -it tlkh/deeplearning-lab:latest bash

# JupyterLab
docker run --rm -p 10000:8888 -e JUPYTER_ENABLE_LAB=yes tlkh/deeplearning-lab:latest
```

## Adapted from the Jupyter Docker Stacks

Please visit the documentation site for help using and contributing to this image and others.

* [Jupyter Docker Stacks on ReadTheDocs](http://jupyter-docker-stacks.readthedocs.io/en/latest/index.html)
* [Selecting an Image :: Core Stacks :: jupyter/base-notebook](http://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html#jupyter-base-notebook)

To build your own high-performance and validated images built from NVIDIA-optimised containers (NGC), see: [https://github.com/tlkh/ngc-2-jupyterhub](https://github.com/tlkh/ngc-2-jupyterhub)
