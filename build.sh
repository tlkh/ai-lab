#!/bin/bash

docker build . -f base.Dockerfile -t nvaitc/ai-lab:0.8-base
docker build . -f full.Dockerfile -t nvaitc/ai-lab:0.8
docker build . -f vnc.Dockerfile -t nvaitc/ai-lab:0.8-vnc
