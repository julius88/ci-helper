FROM debian:buster

ENV DOCKER_VERSION="19.03"

RUN apt update && apt upgrade -y && apt install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        git \
        gnupg2 \
        software-properties-common \
        python3 \
        python3-pip && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" && \
    apt update && \
    apt install -y \
        docker-ce-cli=$(apt-cache policy docker-ce-cli | grep ${DOCKER_VERSION} | head -n1 | awk '{$1=$1};1' | cut -d " " -f1)

RUN mkdir -p ~/.docker/cli-plugins && \
    curl -s https://api.github.com/repos/docker/buildx/releases/latest | \
        grep "browser_download_url.*linux-amd64" | cut -d : -f 2,3 | tr -d \" | \
    xargs curl -L -o ~/.docker/cli-plugins/docker-buildx && \
    chmod a+x ~/.docker/cli-plugins/docker-buildx

RUN pip3 install awscli docker-compose