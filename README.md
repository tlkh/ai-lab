# AI Lab

[![](https://images.microbadger.com/badges/image/nvaitc/ai-lab.svg)](https://microbadger.com/images/nvaitc/ai-lab "Get your own image badge on microbadger.com") [![](https://img.shields.io/github/issues/nvaitc/ai-lab.svg)](Issues) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

All-in-one AI Docker container compatible with JupyterHub and nvidia-docker GPU-accelerated container runtime

## What's Included

* `0.7`: CUDA 9.2 + cuDNN 7 (Ubuntu 18.04.1 base)
* Text editors (like `nano`/`vim`) and utilities like `git`
* Python data science packages
  * `pandas`, `numpy`, `numba`, `sympy`, `scipy` etc.
  * `matplotlib` fonts are pre-cached
  * Extras also included: `nltk`, `gensim`, `opencv`, `scikit-learn`
* RAPIDS and XGBoost (`0.6-cuda9.2`)
* `tensorflow-gpu` and `keras`
* `pytorch` and `torchvision`, `torchtext`
* Jupyter Notebook and JupyterLab
  * including `ipywidgets` and `jupyter_contrib_nbextensions`
  * integrated TensorBoard support

This image is can be used standalone or via JupyterHub.

* To build your own high-performance and validated images built from NVIDIA-optimised containers (NGC), see: [https://github.com/tlkh/ngc-2-jupyterhub](https://github.com/tlkh/ngc-2-jupyterhub)
* For an image with only machine learning and RAPIDS packages, check out [tlkh/ml-lab](https://github.com/tlkh/ml-lab)

## Using this image

```
# Run an interactive shell
docker run -it tlkh/ai-lab

# Run Jupyter Notebook at port 8888 and mount /home/user/USER_DIR as working directory
nvidia-docker run --rm -p 8888:8888 -v /home/user/USER_DIR:/home/jovyan/ tlkh/ai-lab

# Same, but use JupyterLab by default by passing JUPYTER_ENABLE_LAB=yes 
nvidia-docker run --rm -p 8888:8888 -v /home/user/USER_DIR:/home/jovyan/ -e JUPYTER_ENABLE_LAB=yes tlkh/ai-lab
```

## Adapted from the Jupyter Docker Stacks

Please visit the documentation site for help using and contributing to this image and others.

* [Jupyter Docker Stacks on ReadTheDocs](http://jupyter-docker-stacks.readthedocs.io/en/latest/index.html)
* [Selecting an Image :: Core Stacks :: jupyter/base-notebook](http://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html#jupyter-base-notebook)
