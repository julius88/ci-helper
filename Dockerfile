FROM python:3.11-slim-bullseye

ARG DOCKER_VERSION
ARG YQ_VERSION="4.28.1"
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
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/$(dpkg --print-architecture)/kubectl" && \
    curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/$(dpkg --print-architecture)/kubectl.sha256" && \
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

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
