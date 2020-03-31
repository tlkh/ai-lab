## Building the containers

The main [build script](https://github.com/NVAITC/ai-lab/blob/master/build.sh) can be executed with:

```shell
bash build.sh
```

It builds Dockerfiles (found in the `src` folder) into container images in the following order:

| Dockerfile      | Container                | Remarks                     |
| --------------- | ------------------------ | --------------------------- |
| [base.Dockerfile](https://github.com/NVAITC/ai-lab/blob/master/src/base.Dockerfile) | nvaitc/ai-lab:YY.MM-base | Ubuntu+Conda+Jupyter+PyData |
| [tf2.Dockerfile](https://github.com/NVAITC/ai-lab/blob/master/src/tf2.Dockerfile) | nvaitc/ai-lab:YY.MM-tf2  | ++ TensorFlow 2.x           |
| [full.Dockerfile](https://github.com/NVAITC/ai-lab/blob/master/src/full.Dockerfile) | nvaitc/ai-lab:YY.MM      | ++ PyTorch, RAPIDS          |
| [vnc.Dockerfile](https://github.com/NVAITC/ai-lab/blob/master/src/vnc.Dockerfile) | nvaitc/ai-lab:YY.MM-vnc  | ++ VNC Desktop, VirtualGL   |

## Adding additional packages into a container

You can use any of the containers as a base to build your own containers. The entire historical directory of containers can be accessed on [Docker Hub](https://hub.docker.com/r/nvaitc/ai-lab/tags).

**Building your own container**

As a simple example, to add the MXNet framework into container:

```Dockerfile
# create and build this Dockerfile

FROM nvaitc/ai-lab:20.03
LABEL maintainer="You <you@yourdomain.com>"

# you need to use root user for apt-get or make install
#USER root
#RUN apt-get update && apt-get install some-package

# use notebook user for pip/conda
USER $NB_UID
RUN pip install --no-cache-dir mxnet-cu101mkl

# always switch back to notebook user at the end
USER $NB_UID
```

After which, we can build the Dockerfile:

```shell
docker build . -f mxnet.Dockerfile -t myCustomMxNet:latest
```
