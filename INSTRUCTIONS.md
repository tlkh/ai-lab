## Detailed Usage Instructions

This page will give a brief walkthrough on using this image.

To begin, please pull the latest version of the image with:

```bash
docker pull nvaitc/ai-lab:latest
```

Here, we are demonstrating the usage of the container with a freshly installed Ubuntu 18.04 VM with the lightweight XFCE environment. The instructions will apply to any other derivative of Ubuntu 16.04 or Ubuntu 18.04.

## Pre-requisites

You will need to have CUDA>=9.2, Nvidia drivers=>398, Docker and the nvidia-docker2 runtime installed. For a quick and dirty way to ensure this, run the following (no warranty provided, but I use this myself)

```bash
sudo su root
apt install curl -y
curl https://getcuda.ml/ubuntu.sh | bash
# your system will reboot by itself
# find out more @ getcuda.ml
```

### 0. Interactive shell

You can use the container in interactive mode (command line interface).

```bash
nvidia-docker run --rm -it nvaitc/ai-lab bash
```

Note that the default user in the container is always `jovyan`. ([Who is Jovyan?](https://github.com/jupyter/docker-stacks/issues/358)) 

![bash](images/interactive.jpg)

### 1. Jupyter Notebook

We can clone our `quickstart-notebooks` repository and play around with the sample notebooks for several deep learning frameworks.

```bash
# clone the folder to /home/USER/quickstart-notebooks
git clone https://github.com/NVAITC/quickstart-notebooks

# launch the container in that folder and map port 8888
nvidia-docker run --rm -p 8888:8888 -v /home/USER/quickstart-notebooks:/home/jovyan nvaitc/ai-lab
```

![start jupyter](images/start_jupyter_qs.jpg)

Copy and paste the URL on the last line into your browser (you'll need to replace the contents of the bracket with `localhost` or your IP address)

![start jupyter](images/jupyter_qs.jpg)

The first notebook you might want to run is the `hello_gpu.ipynb` notebook to check if you can access your GPU properly.

![hello gpu](images/check_gpu.jpg)

**Here is a breakdown of the command**

* Base command: `nvidia-docker run nvaitc/ai-lab`
* `--rm` flag: remove after container stop
* `-p 8888:8888` : map port 8888 on container to 8888 on host
* `-v /home/USER/quickstart-notebooks:/home/jovyan` : map folder `/home/USER/quickstart-notebooks` on host to working directory of the container (`/home/jovyan`). Please note that **absolute paths** must be used.
