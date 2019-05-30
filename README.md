![header image](images/ai-lab-header.jpg)

[![](https://img.shields.io/docker/pulls/nvaitc/ai-lab.svg)](https://hub.docker.com/r/nvaitc/ai-lab) [![](https://images.microbadger.com/badges/image/nvaitc/ai-lab.svg)](https://microbadger.com/images/nvaitc/ai-lab "Get your own image badge on microbadger.com") [![](https://img.shields.io/github/issues/nvaitc/ai-lab.svg)](Issues) [![](https://img.shields.io/badge/vulnerabilities%20%28snyk.io%29-0-brightgreen.svg)](https://img.shields.io/snyk/vulnerabilities/github/nvaitc/ai-lab/test/requirements.txt.svg?label=vulnerabilities%20%28snyk.io%29)

All-in-one AI development container for rapid prototyping, compatible with the nvidia-docker GPU-accelerated container runtime as well as JupyterHub. This is designed as a lighter and more portable alternative to various cloud provider "Deep Learning Virtual Machines". Get up and running with a wide range of machine learning and deep learning tasks by pulling and running the container on your workstation, on the cloud or within JupyterHub.

## What's Included

* CUDA 10.0 + cuDNN 7 (Ubuntu 18.04 base)
* Packages and libraries
  * DL/ML: TensorFlow/Keras, PyTorch, fast.ai, RAPIDS, XGBoost etc.
  * CV & NLP: `opencv`, `nltk`, `spacy` etc.
  * Distributed: OpenMPI, Horovod, Dask
* Jupyter Notebook and JupyterLab
  * Useful extensions + integrated TensorBoard support
* VNC edition with full desktop environment and various RL libraries
  * Virtual desktop (VNC) is accessed through web interface, no VNC client required

This image can be used with NVIDIA GPUs on workstation or cloud instances, and via JupyterHub deployments.

## Using the AI Lab Container

For full instructions, please take a look at: [INSTRUCTIONS.md](INSTRUCTIONS.md).

**Quick Start**

Pull and run interactive shell (CLI):

```bash
docker pull nvaitc/ai-lab:0.8
# 0.6 is the last version supporting driver < 410

```bash
nvidia-docker run --rm -it nvaitc/ai-lab:0.8 bash
```

Run Jupyter Notebook with the following options:

* forward port 8888 to your host machine
* mount `/home/$USER` as the working directory (`/home/jovyan`)

```bash
nvidia-docker run --rm \
 -p 8888:8888 \
 -v /home/$USER:/home/jovyan \
 nvaitc/ai-lab:0.8
```

Run JupyterLab by setting `JUPYTER_ENABLE_LAB=yes`, or replacing `tree` with `lab` in the browser address bar

```bash
nvidia-docker run --rm \
 -p 8888:8888 \
 -v /home/$USER:/home/jovyan \
 -e JUPYTER_ENABLE_LAB=yes \
 nvaitc/ai-lab:0.8
```

[INSTRUCTIONS.md](INSTRUCTIONS.md) contains full instructions and addresses common questions on [deploying to public cloud (GCP/AWS)](INSTRUCTIONS.md#public-cloud-gcp--aws-etc), as well as using [PyTorch DataLoader](INSTRUCTIONS.md#pytorch-dataloader) or troubleshooting [permission issues](INSTRUCTIONS.md#permission-issues) with some setups.

If you have any ideas or suggestions, please feel free to open an issue.

## FAQ

**1. Can I modify/build this container myself?**

Sure! The `Dockerfile` is provided in this repository. All you need is a fast internet connection and about 50 minutes of time to build this container from scratch. Some packages, like RAPIDS and `pillow-simd`, are built from source.

Should you only require some extra packages, you can build your own Docker image using `nvaitc/ai-lab` as the base image. For example, to add the MXNet framework into container:

```Dockerfile
# create and build this Dockerfile

FROM nvaitc/ai-lab:0.8
LABEL maintainer="You <you@yourdomain.com>"

# you need to use root user for apt-get or make install
#USER root
#RUN apt-get update && apt-get install some-package

# use notebook user for pip/conda
USER $NB_UID
RUN pip install --no-cache-dir mxnet-cu92mkl

# always switch back to notebook user at the end
USER $NB_UID
```

**2. Do you support MXNet/`some-package`?**

See **Point 1** above to see how to add MXNet/`some-package` into the container. I had chosen not to distribute MXNet/`some-package` with the container as it is less widely used and is large in size, and can be easily installed with pip since the environment is already properly configured. If you have a suggestion for a package that you would like to see added, open an issue.

**3. Do you support multi-node or multi-GPU tasks?**

Multi-GPU has been tested with Keras `multi_gpu_model` and Horovod, and it works as expected. However, I have not yet validated multi-node tasks (eg. OpenMPI and Horovod) but the packages are installed. I intend to pay more attention to this in the future.

**4. How does this contrast with NGC containers?**

NVIDIA GPU Cloud ([NGC](https://www.nvidia.com/en-sg/gpu-cloud/)) features NVIDIA tuned, tested, certified, and maintained containers for deep learning and HPC frameworks that take full advantage of NVIDIA GPUs on supported systems, such as [NVIDIA DGX products](https://www.nvidia.com/en-sg/data-center/dgx-systems/). **We recommend the use of NGC containers for mission critical and production workloads.**

The AI Lab container was designed for students and researchers. The container is primarily designed to create a frictionless experience (by including all frameworks) during the initial prototyping and exploration phase, with a focus on iteration with fast feedback and less focus on deciding on specific approaches or frameworks. **This is not an official NVIDIA product!**

If you would like to use NGC containers in an AI Lab like container, there is an example of how you can build one yourself. Take a look at [`tf-amp.Dockerfile`](tf-amp.Dockerfile). Do note that you are restricted from distributing derivative images from NGC containers in a public Docker registry.

## Support

* Core Maintainer: [Timothy Liu (tlkh)](https://github.com/tlkh)
* **This is not an official NVIDIA product!**
* The website, its software and all content found on it are provided on an “as is” and “as available” basis. NVIDIA/NVAITC does not give any warranties, whether express or implied, as to the suitability or usability of the website, its software or any of its content. NVIDIA/NVAITC will not be liable for any loss, whether such loss is direct, indirect, special or consequential, suffered by any party as a result of their use of the libraries or content. Any usage of the libraries is done at the user’s own risk and the user will be solely responsible for any damage to any computer system or loss of data that results from such activities.
* Please open an issue if you encounter problems or have a feature request

**Adapted from the Jupyter Docker Stacks**

* Please visit the documentation site for help using and contributing to this image and others.
* [Jupyter Docker Stacks on ReadTheDocs](http://jupyter-docker-stacks.readthedocs.io/en/latest/index.html)
* [Selecting an Image :: Core Stacks :: jupyter/base-notebook](http://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html#jupyter-base-notebook)
