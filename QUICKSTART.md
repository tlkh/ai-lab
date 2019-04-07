[WIP]

# Quick-start Guide

## Welcome to AI Lab!

AI Lab (`nvaitc/ai-lab`) is an all-in-one AI development container for rapid prototyping. What does that mean? It means that this container (as supporting software) has been painstakingly tailored to provide you with the best out of the box experience to use various Machine Learning and Deep Learning frameworks. These include the usual Python libraries (numpy, pandas), ML libraries (scikit-learn, [xgboost](https://github.com/dmlc/xgboost) and [RAPIDS](https://rapids.ai/)), and Deep Learning frameworks ([TensorFlow](https://www.tensorflow.org/), [PyTorch](https://pytorch.org/)). Where possible, all libraries are GPU-accelerated and optimised for performance.

## Important System Requirements

It is very important that you verify that you meet the following system requirements

1. Ubuntu 16.04, or Ubuntu 18.04, or a close derivative distro
2. Latest stable NVIDIA drivers (currently 418 as of March 2019)
3. NVIDIA container runtime (`nvidia-docker`)
4. NVIDIA Maxwell, Pascal, Volta or Turing GPU
   * If you have a GTX 9-series or newer GPU, you're fine
   * Kepler (e.g. K80) GPUs will not for some libraries (e.g. RAPIDS) but are fine otherwise

If you meet the above requirements, you are free to skip past the next section to "[Before we continue](#before-we-continue)"

## Installing System Requirements

For this, please make sure that you are on a clean Ubuntu system (no existing NVIDIA driver or libraries) and that you have `sudo` permissions. If you need help installing Ubuntu, 

# WIP - INCOMPLETE!!

1. Open a new Terminal.
   * You can usually achieve by pressing <kbd>CTRL</kbd> + <kbd>ALT</kbd> + <kbd>T</kbd> on your keyboard.
   * Else, use your distro's application launcher to launch the Terminal application.
2. Type `sudo su root` and press <kbd>ENTER</kbd>
3. You might need to enter your password. Do so if `Password: ` shows up.
   * Enter your password by typing it in and press <kbd>ENTER</kbd>
   * Do note that you will not see any response (such as `*`) when typing

## Before we continue

If you've never encountered containers, Jupyter notebooks or any of the frameworks mentioned above, please feel free to head over to their website, or check out the articles below.

* What is a Docker container?
* What is Jupyter Notebook? (What is JupyterLab?)
* [Why data scientists love Jupyter](https://www.nature.com/articles/d41586-018-07196-1), and some [tips and tricks to make the best out of it](https://www.datacamp.com/community/blog/jupyter-notebook-cheat-sheet)!

This guide is meant to be a companion to the web GUI and is designed for beginners. 

## Quick tutorial

## Last comments

