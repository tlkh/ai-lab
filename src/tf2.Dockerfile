# Base image built from `base.Dockerfile`

FROM tlkh/ai-lab:20.12-base

LABEL maintainer="Timothy Liu <timothy_liu@mymail.sutd.edu.sg>"

USER root

ENV DEBIAN_FRONTEND=noninteractive \
    TF_FORCE_GPU_ALLOW_GROWTH=true

# install conda TensorFlow

USER $NB_UID
    
RUN cd $HOME/ && \
    conda install -c anaconda --quiet --yes \
      tensorflow-gpu \
      tensorflow-hub \
      tensorflow-datasets && \
    jupyter lab clean && \
    conda clean -tipsy && \
    conda build purge-all && \
    find $CONDA_DIR -type f,l -name '*.a' -delete && \
    find $CONDA_DIR -type f,l -name '*.pyc' -delete && \
    find $CONDA_DIR -type f,l -name '*.js.map' -delete && \
    npm cache clean --force && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf /tmp/* && \
    rm -rf $HOME/.cache && \
    rm -rf $HOME/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions $HOME

# Switch back to jovyan to avoid accidental container runs as root

USER $NB_UID
