FROM nvidia/cuda:11.3.0-devel-ubuntu20.04

# set timezone to Asia/Tokyo
ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# mamba install
ENV MAMBA_ROOT_PREFIX=/opt/conda
ENV PATH=$MAMBA_ROOT_PREFIX/bin:$PATH

RUN apt update && apt install curl --yes \
    && curl -L https://micromamba.snakepit.net/api/micromamba/linux-64/latest | tar -xj "bin/micromamba" \
    && touch /root/.bashrc \
    && ./bin/micromamba shell init -s bash -p $MAMBA_ROOT_PREFIX  \
    && grep -v '[ -z "\$PS1" ] && return' /root/.bashrc  > $MAMBA_ROOT_PREFIX/bashrc

# create a new conda environment and activate it
COPY ./pytorch-py3_8.yaml /tmp/pytorch-py3_8.yaml
RUN micromamba create -f /tmp/pytorch-py3_8.yaml
ENV PATH $MAMBA_ROOT_PREFIX/envs/pytorch-py3_8/bin:$PATH

# clean packages
RUN micromamba clean --all --yes

# expose port 8888 for JupytorLab
EXPOSE 8888

# set the working directory to /simple-cla
WORKDIR /simple-classification-with-bbc-dataset

# mount the current directory on the host to /simple-classification-with-bbc-dataset in the container
COPY . /simple-classification-with-bbc-dataset
