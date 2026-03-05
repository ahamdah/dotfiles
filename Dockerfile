FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /dotfiles

COPY . /dotfiles

RUN chmod +x scripts/setup.sh

ENTRYPOINT ["/dotfiles/scripts/setup.sh"]
