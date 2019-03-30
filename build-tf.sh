#!/usr/bin/env bash

echo '[INFO ] Building Base Image'
docker build . -f build/Dockerfile.build.base-cu100-cudnn75 -t nvaitc/ai-lab:build-base-cu100-cudnn75

echo '[INFO ] Building TensorFlow with XLA'
docker build . -f build/Dockerfile.build.tf-cu100-cudnn75-broadwell-xla -t nvaitc/ai-lab:build-tf-cu100-cudnn75-broadwell-xla

echo '[INFO ] Building TensorFlow without XLA'
docker build . -f build/Dockerfile.build.tf-cu100-cudnn75-broadwell -t nvaitc/ai-lab:build-tf-cu100-cudnn75-broadwell

echo '[INFO ] Exporting binary wheels'
docker run -v $(pwd)/build:/home/jovyan nvaitc/ai-lab:build-tf-cu100-cudnn75-broadwell-xla bash -c 'cp /output/*.whl /home/jovyan'
docker run -v $(pwd)/build:/home/jovyan nvaitc/ai-lab:build-tf-cu100-cudnn75-broadwell bash -c 'cp /output/*.whl /home/jovyan'

