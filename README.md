# Deep Learning Lab

[![](https://images.microbadger.com/badges/image/tlkh/deeplearning-lab.svg)](https://microbadger.com/images/tlkh/deeplearning-lab "Get your own image badge on microbadger.com") [![](https://img.shields.io/github/issues/tlkh/deeplearning-lab.svg)](Issues) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

All-in-one Deep Learning with Jupyter Notebook/Lab and nvidia-docker

## What's Included

* CUDA 9.0 (Ubuntu 16.04 base)
* Text editors (like `nano`) and utlities like `git`
* Python data science packages
  * `pandas`, `numpy`, `numba`, `sympy`, `scipy` etc.
  * `matplotlib` is pre-cached
  * Extras also included: `nltk`, `gensim`, `opencv`, `scikit-learn`
* `tensorflow-gpu` and `keras`
* `pytorch` and `torchvision`
* Jupyter Notebook and JupyterLab
  * including `ipywidgets` and `jupyter_contrib_nbextensions`

This image is compatible with JupyterHub.

## Using this image

```
DRAFT

Examples:

docker run -p 8888:8888 tlkh/deeplearning-lab:latest

docker run --rm -p 10000:8888 -e JUPYTER_ENABLE_LAB=yes tlkh/deeplearning-lab:latest
```

## Forked from the Jupyter Docker Stacks

Please visit the documentation site for help using and contributing to this image and others.

* [Jupyter Docker Stacks on ReadTheDocs](http://jupyter-docker-stacks.readthedocs.io/en/latest/index.html)
* [Selecting an Image :: Core Stacks :: jupyter/base-notebook](http://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html#jupyter-base-notebook)
