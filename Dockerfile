FROM alpine:latest

LABEL maintainer="István Antal <istvan@antal.xyz>"

ARG HOME=/var/lib/bastion

#ARG USER=bastion
#ARG GROUP=bastion
#ARG UID=4096
#ARG GID=4096

ARG USER=root
ARG GROUP=root

ENV HOST_KEYS_PATH_PREFIX="/usr"
ENV HOST_KEYS_PATH="${HOST_KEYS_PATH_PREFIX}/etc/ssh"

COPY bastion.sh /usr/sbin/bastion.sh

RUN apk add --no-cache openssh-server && \
    apk add --no-cache rsync && \
    echo "Welcome to Bastion!" > /etc/motd && \
    chmod +x /usr/sbin/bastion.sh && \
    mkdir -p ${HOST_KEYS_PATH} && \
    mkdir /etc/ssh/auth_principals && \
    echo "bastion" > /etc/ssh/auth_principals/$USER

COPY sshd_config /etc/ssh/sshd_config

EXPOSE 22

ENTRYPOINT ["/usr/sbin/bastion.sh"]