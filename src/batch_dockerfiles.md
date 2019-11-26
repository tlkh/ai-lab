## Dockerfile for Batch Workload

Slimmed-down Dockerfiles (and the built containers) are available for batch workload systems.

These containers do not include packages such as Jupyter notebook.

### Files

| tag        | Dockerfile |
| ---------- | ---------- |
| `batch-base` | [Dockerfile](https://github.com/NVAITC/ai-lab/blob/master/src/base-batch.Dockerfile) |
| `batch-tf1` | [Dockerfile](https://github.com/NVAITC/ai-lab/blob/master/src/batch-tf1.Dockerfile) |
| `batch-tf2` | [Dockerfile](https://github.com/NVAITC/ai-lab/blob/master/src/batch-tf2.Dockerfile) |

### Packages Included

**`batch-base` : Python + PyData + PyTorch + RAPIDS**

* Python 3.6 + Conda
* NumPy, Pandas, Scikit-learn, lightgbm, numba
* PyTorch 1.x, Torchvision, Apex
* OpenCV, Pillow-SIMD, NLTK, Spacy
* HuggingFace Transformers
* RAPIDS: cuDF, cuML, cuGraph, XGBoost, Dask

```
TODO: Ptflop, NVIDIA DALI
```

**`batch-tf1`: `batch-base` + TensorFlow 1.x**

* TensorFlow 1.x
* OpenMPI, Horovod

**`batch-tf2`: `batch-base` + TensorFlow 2.x**

* TensorFlow 2.x
* TF IO, AddOns, Datasets, Hub, Probability, Model Optimization packages
* Keras Tuner
* OpenMPI, Horovod
