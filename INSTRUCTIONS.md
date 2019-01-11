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

### 1. Deep Learning

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

### 2. RAPIDS

#### Setup

`git clone https://github.com/tlkh/RAPIDS-demo`

![starting](images/start.jpg)

The dataset (`drive_data`) can be downloaded from [Google Drive](https://drive.google.com/file/d/1VFyqGKVVI4t15Xp9zdFdk7068IZYxn84/view?usp=sharing).

#### Running the sample

Launch the container with the working directory as the `RAPIDS-demo` folder using the following command:

```bash
nvidia-docker run --rm -p 8888:8888 -v /home/nvaitc/RAPIDS-demo:/home/jovyan nvaitc/ai-lab
```

**Here is a breakdown of the command**

* Base command: `nvidia-docker run nvaitc/ai-lab`
* `--rm` flag: remove after container stop
* `-p 8888:8888` : map port 8888 on container to 8888 on host
* `-v /home/nvaitc/RAPIDS-demo:/home/jovyan` : map folder `/home/nvaitc/RAPIDS-demo` on host to working directory of the container (`/home/jovyan`). Please note that **absolute paths** must be used.

The Jupyter environment will start automatically. You will see the following output. The last line tells you how to access the Jupyter environment from your browser.

![docker run](images/docker_run.jpg)

When you access the URL, you should be able to see the following screen:

![](images/jupyter.jpg)

You can run the sample notebook `simple_sklearn.ipynb` to do a quick test and observe if the GPU is working properly. You may use `nvidia-smi` or `nvtop` ([install instructions](https://github.com/Syllo/nvtop/blob/master/README.markdown))

![](images/run_jupyter.jpg)
