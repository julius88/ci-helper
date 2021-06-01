FROM debian:buster

ENV DOCKER_VERSION="19.03"

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

RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    add-apt-repository "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/debian $(lsb_release -cs) stable" && \
    apt update && \
    apt install -y \
        docker-ce-cli=$(apt-cache policy docker-ce-cli | grep ${DOCKER_VERSION} | head -n1 | awk '{$1=$1};1' | cut -d " " -f1)

RUN mkdir -p ~/.docker/cli-plugins && \
    curl -s https://api.github.com/repos/docker/buildx/releases/latest | \
        grep "browser_download_url.*linux-$(dpkg --print-architecture)" | cut -d : -f 2,3 | tr -d \" | \
    xargs curl -L -o ~/.docker/cli-plugins/docker-buildx && \
    chmod a+x ~/.docker/cli-plugins/docker-buildx

RUN curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list && \
    apt update && \
    apt install -y kubectl

RUN wget https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv4.1.3/kustomize_v4.1.3_linux_$(dpkg --print-architecture).tar.gz && \
    tar -xzvf kustomize_v4.1.3_linux_$(dpkg --print-architecture).tar.gz -C /usr/bin/

RUN pip3 install awscli docker-compose