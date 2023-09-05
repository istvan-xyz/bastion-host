#!/usr/bin/env sh
set -x

HOST_KEYS_PATH_PREFIX="${HOST_KEYS_PATH_PREFIX:='/'}"
HOST_KEYS_PATH="${HOST_KEYS_PATH:='/etc/ssh'}"

if [ "$PUBKEY_AUTHENTICATION" == "false" ]; then
    CONFIG_PUBKEY_AUTHENTICATION="-o PubkeyAuthentication=no"
else
    CONFIG_PUBKEY_AUTHENTICATION="-o PubkeyAuthentication=yes"
fi

if [ -n "$AUTHORIZED_KEYS" ]; then
    mkdir -p  ~/.ssh
    echo "$AUTHORIZED_KEYS" >> ~/.ssh/authorized_keys
else
    mkdir -p ~/.ssh
    cp /mnt/bastion/authorized_keys ~/.ssh/
    chmod 600 ~/.ssh/authorized_keys
    # CONFIG_AUTHORIZED_KEYS="-o AuthorizedKeysFile=$AUTHORIZED_KEYS"

    # CONFIG_AUTHORIZED_KEYS="-o AuthorizedKeysFile=authorized_keys"
fi

# if [ -n "$TRUSTED_USER_CA_KEYS" ]; then
#     CONFIG_TRUSTED_USER_CA_KEYS="-o TrustedUserCAKeys=$TRUSTED_USER_CA_KEYS"
#     CONFIG_AUTHORIZED_PRINCIPALS_FILE="-o AuthorizedPrincipalsFile=/etc/ssh/auth_principals/%u"
# fi

if [ "$GATEWAY_PORTS" == "true" ]; then
    CONFIG_GATEWAY_PORTS="-o GatewayPorts=yes"
else
    CONFIG_GATEWAY_PORTS="-o GatewayPorts=no"
fi

if [ "$PERMIT_TUNNEL" == "true" ]; then
    CONFIG_PERMIT_TUNNEL="-o PermitTunnel=yes"
else
    CONFIG_PERMIT_TUNNEL="-o PermitTunnel=no"
fi


if [ "$AGENT_FORWARDING" == "false" ]; then
    CONFIG_AGENT_FORWARDING="-o AllowAgentForwarding=no"
else
    CONFIG_AGENT_FORWARDING="-o AllowAgentForwarding=yes"
fi

if [ ! -f "$HOST_KEYS_PATH/ssh_host_rsa_key" ]; then
    /usr/bin/ssh-keygen -A -f "$HOST_KEYS_PATH_PREFIX"
fi

if [ -n "$LISTEN_ADDRESS" ]; then
    CONFIG_LISTEN_ADDRESS="-o ListenAddress=$LISTEN_ADDRESS"
else
    CONFIG_LISTEN_ADDRESS="-o ListenAddress=0.0.0.0"
fi

if [ -n "$LISTEN_PORT" ]; then
    CONFIG_LISTEN_PORT="-o Port=$LISTEN_PORT"
else
    CONFIG_LISTEN_PORT="-o Port=22"
fi

/usr/sbin/sshd -D -e -4 \
    -o "HostKey=$HOST_KEYS_PATH/ssh_host_rsa_key" \
    -o "HostKey=$HOST_KEYS_PATH/ssh_host_dsa_key" \
    -o "HostKey=$HOST_KEYS_PATH/ssh_host_ecdsa_key" \
    -o "HostKey=$HOST_KEYS_PATH/ssh_host_ed25519_key" \
    -o "PasswordAuthentication=no" \
    -o "PermitEmptyPasswords=no" \
    -o "PermitRootLogin=yes" \
    -o "X11Forwarding=yes" \
    -o "AllowTcpForwarding=yes" \
    -o "AuthorizedKeysFile=%h/.ssh/authorized_keys" \
    $CONFIG_PUBKEY_AUTHENTICATION \
    $CONFIG_AUTHORIZED_KEYS \
    $CONFIG_GATEWAY_PORTS \
    $CONFIG_PERMIT_TUNNEL \
    $CONFIG_AGENT_FORWARDING \
    $CONFIG_LISTEN_ADDRESS \
    $CONFIG_LISTEN_PORT
