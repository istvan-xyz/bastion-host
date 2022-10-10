FROM alpine:latest

LABEL maintainer="István Antal <istvan@antal.xyz>"

ARG HOME=/var/lib/bastion

ARG USER=bastion
ARG GROUP=bastion
ARG UID=4096
ARG GID=4096

ENV HOST_KEYS_PATH_PREFIX="/usr"
ENV HOST_KEYS_PATH="${HOST_KEYS_PATH_PREFIX}/etc/ssh"

COPY bastion.sh /usr/sbin/bastion.sh

RUN addgroup -S -g ${GID} ${GROUP} \
    && adduser -D -h ${HOME} -s /bin/ash -g "${USER} service" \
           -u ${UID} -G ${GROUP} ${USER} \
    && sed -i "s/${USER}:!/${USER}:*/g" /etc/shadow \
    && set -x \
    && apk add --no-cache openssh-server && \
    apk add --no-cache rsync && \
    echo "Welcome to Bastion!" > /etc/motd \
    && chmod +x /usr/sbin/bastion.sh \
    && mkdir -p ${HOST_KEYS_PATH} \
    && mkdir /etc/ssh/auth_principals \
    && echo "bastion" > /etc/ssh/auth_principals/bastion

EXPOSE 22/tcp

VOLUME ${HOST_KEYS_PATH}

ENTRYPOINT ["bastion.sh"]