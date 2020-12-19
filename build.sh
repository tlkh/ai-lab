#!/bin/bash

TAG=20.12

cd src

echo -e "\nBuilding images\n"

docker build . -f base.Dockerfile -t tlkh/ai-lab:$TAG-base
docker build . -f full.Dockerfile -t tlkh/ai-lab:$TAG
docker build . -f vnc.Dockerfile -t tlkh/ai-lab:$TAG-vnc

echo -e "\nPushing images\n"

docker push tlkh/ai-lab:$TAG-base
docker push tlkh/ai-lab:$TAG
docker push tlkh/ai-lab:$TAG-vnc
