# syntax=docker/dockerfile:1
FROM continuumio/miniconda3:23.10.0-1  AS builder

RUN apt-get update && apt-get install -y build-essential ghostscript

WORKDIR /tmp/
COPY environment.yml /tmp/environment.yml
RUN conda env create -f /tmp/environment.yml && \
    conda clean -a && conda init bash && echo "conda activate $(head -1 environment.yml | cut -d' ' -f2)" >> ~/.bashrc && \
    rm environment.yml

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

# the base docker image defines workdir in /app
# however, here we need (?) to run as user jovyan
# and some jupyter lab functionalities do not work when dropped into (root-owned?) /app
WORKDIR ${HOME}


