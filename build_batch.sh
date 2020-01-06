#!/bin/bash

TAG=20.01

cd src

echo -e "\nBuilding images\n"

docker build . -f base-batch.Dockerfile -t nvaitc/ai-lab:$TAG-batch-base
docker build . -f batch-tf1.Dockerfile -t nvaitc/ai-lab:$TAG-batch-tf1
docker build . -f batch-tf2.Dockerfile -t nvaitc/ai-lab:$TAG-batch-tf2

docker build . -f base-batch.Dockerfile -t nvcr.io/nvidian/sae/ai-lab:$TAG-batch-base
docker build . -f batch-tf1.Dockerfile -t nvcr.io/nvidian/sae/ai-lab:$TAG-batch-tf1
docker build . -f batch-tf2.Dockerfile -t nvcr.io/nvidian/sae/ai-lab:$TAG-batch-tf2

echo -e "\nPushing images\n"

docker push nvaitc/ai-lab:$TAG-batch-base
docker push nvaitc/ai-lab:$TAG-batch-tf1
docker push nvaitc/ai-lab:$TAG-batch-tf2

docker push nvcr.io/nvidian/sae/ai-lab:$TAG-batch-base
docker push nvcr.io/nvidian/sae/ai-lab:$TAG-batch-tf1
docker push nvcr.io/nvidian/sae/ai-lab:$TAG-batch-tf2

