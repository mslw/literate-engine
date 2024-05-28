# syntax=docker/dockerfile:1
FROM nest/nest-simulator:2.20.2

RUN apt-get update && apt-get install -y build-essential ghostscript

# --- required by binder ---
# https://mybinder.readthedocs.io/en/latest/tutorials/dockerfile.html

RUN python3 -m pip install --no-cache-dir notebook jupyterlab bash_kernel
RUN python -m bash_kernel.install

ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

# Make sure the contents of our repo are in ${HOME}
COPY . ${HOME}
USER root
RUN chown -R ${NB_UID} ${HOME}
USER ${NB_USER}

