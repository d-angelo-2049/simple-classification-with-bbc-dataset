FROM nvidia/cuda:11.3.0-devel-ubuntu20.04

# set timezone to Asia/Tokyo
ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# install Anaconda

# Condaのインストール
ENV MINICONDA_VERSION py38_4.10.3
ENV CONDA_DIR /opt/conda

RUN apt update && \
    apt install -y curl && \
    curl -sLo ~/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-$MINICONDA_VERSION-Linux-x86_64.sh && \
    chmod +x ~/miniconda.sh && \
    ~/miniconda.sh -b -p $CONDA_DIR && \
    rm ~/miniconda.sh

# Activate conda in non-interactive shell
RUN /opt/conda/bin/conda init bash

# create a new conda environment and activate it
COPY ./pytorch-py3_8.yaml /tmp/pytorch-py3_8.yaml
RUN $CONDA_DIR/bin/conda env create -f /tmp/pytorch-py3_8.yaml
ENV PATH $CONDA_DIR/envs/pytorch-py3_8/bin:$PATH
RUN echo "conda activate pytorch-py3_8" >> ~/.bashrc

# clean packages
RUN /opt/conda/bin/conda clean --all --yes

# enable SSH
RUN apt install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN echo "export VISIBLE=now" >> /etc/profile

# expose port 22 for SSH, port 8888 for JupytorLab
EXPOSE 22 8888

# set the working directory to /simple-cla
WORKDIR /simple-classification-with-bbc-dataset

# mount the current directory on the host to /simple-classification-with-bbc-dataset in the container
COPY . /simple-classification-with-bbc-dataset

SHELL ["/bin/bash", "-c", "source ~/.bashrc && conda activate pytorch-py3_8"]
