FROM python:3.9-slim-bullseye

ARG DOCKER_VERSION
ARG YQ_VERSION="4.27.2"
ARG KUSTOMIZE_VERSION="4.5.7"
ARG NODE_VERSION="16"

# Install dependencies.
RUN apt update && apt upgrade -y && apt install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        git \
        jq \
        rsync \
        wget \
        openssh-client \
        build-essential \
        libssl-dev \
        libffi-dev \
        gnupg2 \
        software-properties-common \
        python3 \
        python3-dev \
        python3-pip

# Install Docker.
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    add-apt-repository "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/debian $(lsb_release -cs) stable" && \
    apt update && \
    apt install -y \
        docker-ce-cli=$(apt-cache madison docker-ce-cli | grep ${DOCKER_VERSION} | head -n1 | awk '{print $3}')

# Install awscli and docker-compose.
RUN pip3 install pip setuptools --upgrade --no-cache-dir && \
    pip3 install awscli docker-compose --no-cache-dir

# Install buildx plugin for Docker.
RUN mkdir -p ~/.docker/cli-plugins && \
    curl -s https://api.github.com/repos/docker/buildx/releases/latest | \
        grep "browser_download_url.*linux-$(dpkg --print-architecture)" | cut -d : -f 2,3 | tr -d \" | \
    xargs curl -L -o ~/.docker/cli-plugins/docker-buildx && \
    chmod a+x ~/.docker/cli-plugins/docker-buildx

# Install kubectl.
RUN curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list && \
    apt update && \
    apt install -y kubectl

# Install Kustomize.
RUN wget https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZE_VERSION}/kustomize_v${KUSTOMIZE_VERSION}_linux_$(dpkg --print-architecture).tar.gz && \
    tar -xzvf kustomize_v${KUSTOMIZE_VERSION}_linux_$(dpkg --print-architecture).tar.gz -C /usr/bin/

# Install yq.
RUN wget https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_$(dpkg --print-architecture) -O /usr/bin/yq && chmod +x /usr/bin/yq

# Install yarn.
RUN curl -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - && \
    apt-get install -y nodejs && \
    npm install --global yarn

# Clean up.
RUN rm -rf *.tar.gz && \
    apt clean -y && \
    rm -rf /var/lib/apt/lists/*
