#!/bin/bash
source activate rapids
jupyter notebook --allow-root --ip=0.0.0.0 --no-browser --NotebookApp.token=''