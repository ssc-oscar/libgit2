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
    libbz2-dev \
    lsof sudo \
    sssd \
    sssd-tools \
    vim pkg-config  libssh2-1 libssh2-1-dev \
    git \
    curl lsb-release \
    vim-runtime tmux  zsh zip build-essential \
    cmake build-essential	 


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


RUN mkdir /src 
COPY Compress-LZF-3.41.tar.gz tokyocabinet-perl-1.34.tar.gz tokyocabinet-1.4.48.tar.gz  /src/ 
COPY cleanBlb.perl *.sh  grabGitI.perl /usr/bin/ 
    
RUN cd /src && tar xzf Compress-LZF-3.41.tar.gz && tar xzf tokyocabinet-perl-1.34.tar.gz && tar xzf tokyocabinet-1.4.48.tar.gz \
    && cd /src/Compress-LZF-3.41 && perl Makefile.PL && make && make install \
    && cd /src/tokyocabinet-1.4.48 && ./configure && make && make install \
    && cd /src/tokyocabinet-perl-1.34 && perl Makefile.PL && make && make install


ENV NB_USER audris
ENV NB_UID 50954
ENV HOME /home/$NB_USER
RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && mkdir $HOME/.ssh && chown -R $NB_USER:users $HOME 
COPY id_rsa_gcloud.pub $HOME/.ssh/authorized_keys
RUN chown -R $NB_USER:users $HOME && chmod -R og-rwx $HOME/.ssh


RUN set -x && cd /src \
    && git clone https://github.com/ssc-oscar/libgit2 \ 
    && mkdir -p /src/libgit2/build && cd /src/libgit2/build \
    && cmake .. -DCMAKE_INSTALL_PREFIX=/usr \
    && cmake --build . \
    && make install        \
    && chmod +x /usr/bin/classify  /usr/bin/grab* /usr/bin/get_last /usr/bin/get_new_commits
