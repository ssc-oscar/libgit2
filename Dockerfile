FROM ubuntu:16.04

MAINTAINER Audris Mockus <audris@mockus.org>

USER root

RUN apt-get update && apt install -y  gnupg apt-transport-https


RUN apt-get update && \
    apt-get install -y \
    locales \
    libssl-dev \
    libcurl4-openssl-dev \
    openssh-server \
    lsof sudo \
    sssd \
    sssd-tools \
    vim \
    git \
    curl lsb-release \
    vim-runtime tmux  zsh zip build-essential \
    cmake	 


#Google Cloud 
RUN echo "deb http://packages.cloud.google.com/apt cloud-sdk-$(lsb_release -c -s) main" | tee /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN apt-get update && \
    apt-get install -y google-cloud-sdk

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

ENV LC_ALL=C

COPY eecsCA_v3.crt /etc/ssl/ 
COPY sssd.conf /etc/sssd/ 
COPY common* /etc/pam.d/ 
RUN chmod 0600 /etc/sssd/sssd.conf /etc/pam.d/common* 
RUN if [ ! -d /var/run/sshd ]; then mkdir /var/run/sshd; chmod 0755 /var/run/sshd; fi

#install docker-machine
RUN curl -L https://github.com/docker/machine/releases/download/v0.14.0/docker-machine-`uname -s`-`uname -m` > /usr/local/bin/docker-machine && \
    chmod +x /usr/local/bin/docker-machine


COPY startshell.sh /bin/ 

ENV NB_USER jovyan
ENV NB_UID 1000
ENV HOME /home/$NB_USER
RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && mkdir $HOME/.ssh && chown -R $NB_USER:users $HOME 
COPY id_rsa_gcloud.pub $HOME/.ssh/authorized_keys
RUN chown -R $NB_USER:users $HOME && chmod -R og-rwx $HOME/.ssh

RUN set -x && cd /src && \
    && git clone https://github.com/ssc-oscar/libgit2 \ 
	 && mkdir -p /src/libgit2/build && cd /src/libgit2/build && \\
         cmake .. -DBUILD_SHARED_LIBS=OFF && cmake --build .         
