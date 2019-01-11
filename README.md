![](images/ai-lab-header.jpg)

[![](https://img.shields.io/docker/pulls/nvaitc/ai-lab.svg)](https://hub.docker.com/r/nvaitc/ai-lab) [![](https://images.microbadger.com/badges/image/nvaitc/ai-lab.svg)](https://microbadger.com/images/nvaitc/ai-lab "Get your own image badge on microbadger.com") [![](https://img.shields.io/github/issues/nvaitc/ai-lab.svg)](Issues) [![](https://img.shields.io/badge/vulnerabilities%20(snyk.io)-0-brightgreen.svg)](https://img.shields.io/snyk/vulnerabilities/github/nvaitc/ai-lab/test/requirements.txt.svg?label=vulnerabilities%20%28snyk.io%29)

All-in-one AI Docker container, compatible with the nvidia-docker GPU-accelerated container runtime as well as JupyterHub. Get up and running with machine learning and deep learning just by pulling and running the container on your workstation, on the cloud or within JupyterHub.

## What's Included

* CUDA 9.2 + cuDNN 7.4 (Ubuntu 18.04.1 base)
* Text editors (like `nano`/`vim`) and utilities like `git`
* Python data science packages
  * `pandas`, `numpy`, `numba`, `sympy`, `scipy` etc.
  * NLP and CV Libraries:  `nltk`, `gensim`, `opencv`, `scikit-learn` etc.
* RAPIDS and XGBoost 
* `tensorflow-gpu` and `keras`
* `pytorch` and `torchvision`, `torchtext`
* Jupyter Notebook and JupyterLab
  * including `ipywidgets` and `jupyter_contrib_nbextensions`
  * integrated TensorBoard support

This image can be used standalone on workstation or cloud instances, or via JupyterHub.

## Using the AI Lab Container

Pulling the container:

```bash
docker pull nvaitc/ai-lab:latest
```

Running an interactive shell (`bash`)

```bash
nvidia-docker run --rm -it tlkh/ai-lab bash
```

Run Jupyter Notebook with the following options:

* forward port 8888 to your host machine
* mount `/home/user/USER_DIR` as the working directory (`/home/jovyan`)

```bash
nvidia-docker run --rm -p 8888:8888 -v /home/user/USER_DIR:/home/jovyan tlkh/ai-lab
```

Run JupyterLab by setting `JUPYTER_ENABLE_LAB=yes`

```bash
nvidia-docker run --rm -p 8888:8888 -v /home/user/USER_DIR:/home/jovyan -e JUPYTER_ENABLE_LAB=yes tlkh/ai-lab
```

For detailed instructions and tutorial, see: [INSTRUCTIONS.md](INSTRUCTIONS.md)

## Support

* Core Maintainer: [Timothy Liu (tlkh)](https://github.com/tlkh)
* **This is not an official NVIDIA product!** There is no warranty, liability or support associated with this product. We make no guarantees take no responsibility for any loss or damage resulting from the use of this product.
* Please open an issue if you encounter problems or have a feature request

**Adapted from the Jupyter Docker Stacks**

* Please visit the documentation site for help using and contributing to this image and others.
* [Jupyter Docker Stacks on ReadTheDocs](http://jupyter-docker-stacks.readthedocs.io/en/latest/index.html)
* [Selecting an Image :: Core Stacks :: jupyter/base-notebook](http://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html#jupyter-base-notebook)
