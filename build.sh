#!/bin/bash

TAG=0.8 

echo -e "\nBuilding images\n"

docker build . -f base.Dockerfile -t nvaitc/ai-lab:$TAG-base
docker build . -f full.Dockerfile -t nvaitc/ai-lab:$TAG
docker build . -f vnc.Dockerfile -t nvaitc/ai-lab:$TAG-vnc

echo -e "\nPushing images\n"

docker push nvaitc/ai-lab:$TAG-base
docker push nvaitc/ai-lab:$TAG
docker push nvaitc/ai-lab:$TAG-vnc
