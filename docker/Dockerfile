FROM ubuntu:latest AS base
WORKDIR /usr/local/bin
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y software-properties-common curl git build-essential sudo && \
    apt-add-repository -y ppa:ansible/ansible && \
    apt-get update && \
    apt-get install -y ansible && \
    apt-get clean autoclean && \
    apt-get autoremove --yes

FROM base AS via
RUN addgroup --gid 1000 via && \
    adduser --gecos via --uid 1000 --gid 1000 --disabled-password via && \
    echo "via ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER via
WORKDIR /home/via

FROM via
COPY --chown=via:via .. /home/via/dotfiles
CMD ["bash", "-c", "cd /home/via/dotfiles && ./install.sh"]
