![header image](images/ai-lab-header.jpg)

[![](https://img.shields.io/docker/pulls/nvaitc/ai-lab.svg)](https://hub.docker.com/r/nvaitc/ai-lab) [![](https://images.microbadger.com/badges/image/nvaitc/ai-lab.svg)](https://microbadger.com/images/nvaitc/ai-lab "Get your own image badge on microbadger.com") [![](https://img.shields.io/github/issues/nvaitc/ai-lab.svg)](Issues) [![](https://img.shields.io/badge/vulnerabilities%20%28snyk.io%29-0-brightgreen.svg)](https://img.shields.io/snyk/vulnerabilities/github/nvaitc/ai-lab/test/requirements.txt.svg?label=vulnerabilities%20%28snyk.io%29)

All-in-one AI development container, compatible with the nvidia-docker GPU-accelerated container runtime as well as JupyterHub. Get up and running with machine learning and deep learning just by pulling and running the container on your workstation, on the cloud or within JupyterHub.

## What's Included

* CUDA 9.2 + cuDNN 7.4 (Ubuntu 18.04.1 base)
* Packages and libraries
  * Data Science: `pandas`, `numpy`, `scipy`, `numba` etc.
  * Deep Learning: TensorFlow, PyTorch, MXNet, fast.ai, Keras, Autokeras
  * ML: `scikit-learn`, XGBoost, `lightgbm`
  * RAPIDS: cuDF, cuML, cuGraph
  * CV: `opencv-contrib-python`, `scikit-image`, `pillow-simd`
  * NLP: `nltk`, `spacy`, `flair`
  * Distributed: OpenMPI, Horovod, Dask
* Jupyter Notebook and JupyterLab
  * including `ipywidgets` and `jupyter_contrib_nbextensions`
  * integrated TensorBoard support

This image can be used standalone on workstation or cloud instances, or via JupyterHub instances.

## Using the AI Lab Container

Pulling the container:

```bash
docker pull nvaitc/ai-lab:latest
```

Running an interactive shell (`bash`)

```bash
nvidia-docker run --rm -it nvaitc/ai-lab bash
```

Run Jupyter Notebook with the following options:

* forward port 8888 to your host machine
* mount `/home/user/USER_DIR` as the working directory (`/home/jovyan`)

```bash
nvidia-docker run --rm -p 8888:8888 -v /home/user/USER_DIR:/home/jovyan nvaitc/ai-lab
```

Run JupyterLab by setting `JUPYTER_ENABLE_LAB=yes`, or replacing `tree` with `lab` in the browser address bar

```bash
nvidia-docker run --rm -p 8888:8888 -v /home/user/USER_DIR:/home/jovyan -e JUPYTER_ENABLE_LAB=yes nvaitc/ai-lab
```

For detailed instructions and tutorial, see: [INSTRUCTIONS.md](INSTRUCTIONS.md)

## Support

* Core Maintainer: [Timothy Liu (tlkh)](https://github.com/tlkh)
* **This is not an official NVIDIA product!**
* The website, its software and all content found on it are provided on an “as is” and “as available” basis. NVIDIA/NVAITC does not give any warranties, whether express or implied, as to the suitability or usability of the website, its software or any of its content. NVIDIA/NVAITC will not be liable for any loss, whether such loss is direct, indirect, special or consequential, suffered by any party as a result of their use of the libraries or content. Any usage of the libraries is done at the user’s own risk and the user will be solely responsible for any damage to any computer system or loss of data that results from such activities.
* Please open an issue if you encounter problems or have a feature request

**Adapted from the Jupyter Docker Stacks**

* Please visit the documentation site for help using and contributing to this image and others.
* [Jupyter Docker Stacks on ReadTheDocs](http://jupyter-docker-stacks.readthedocs.io/en/latest/index.html)
* [Selecting an Image :: Core Stacks :: jupyter/base-notebook](http://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html#jupyter-base-notebook)
