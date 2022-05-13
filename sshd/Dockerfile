FROM alpine:3

LABEL version="1.0"
LABEL org.opencontainers.image.authors="Steve Groom stevereg1@groom.ch"
LABEL org.opencontainers.image.source="https://github.com/stevegroom/sshd"
LABEL org.opencontainers.image.description="openssh server to act as a jump \
box into a private network"

#
# Steve Groom May 2022
#
# This dockerfile creates an openssh server with:
#  Zero config
#  No passwords
#  Persistent host keys
#  Persistent authorised keys
#
# This can be used as a jump box into a private network. As the keys used are persisted
# outside the container, the ssh image can be recreated at will without having to 
# update its authorized_keys or your known_hosts files.

# Install the openssh server
RUN apk add --update --no-cache openssh

# Two step process to update the parameters
# Append the desired overrides to the end of the sshd_config file

RUN echo -e "PasswordAuthentication no\n\
PubkeyAuthentication yes\n\
KbdInteractiveAuthentication no\n\
AllowTcpForwarding yes\n\
" >> /etc/ssh/sshd_config

# As ssh accepts only the first instance of a parameter, explicitly
# set unwanted options need to be edited

RUN sed -i -e 's/PasswordAuthentication yes/PasswordAuthentication no/g' \
        -e 's/PubkeyAuthentication no/PubkeyAuthentication yes/g' \
        -e 's/KbdInteractiveAuthentication yes/KbdInteractiveAuthentication no/g' \
        -e 's/AllowTcpForwarding no/AllowTcpForwarding yes/g' /etc/ssh/sshd_config

# Create a user on the server that we use to jump into the private network 
RUN adduser -h /home/shelluser -s /bin/sh -D shelluser

# Password must have any value set before ssh-keygen will succeed (see entrypoint.sh)
# Set password to a random value that is not shown.
RUN echo -n 'shelluser:$(echo $RANDOM | base64 | head -c 20; echo)' | chpasswd

# Open SSH listening on standard port
EXPOSE 22


# Addauthuser.sh - append your personal rsa pub key to shellusers 
# authorized_keys to allow unprompted logon 
COPY addauthuser.sh /

# Entrypoint.sh - conditionally generate certificates and start the daemon.
COPY entrypoint.sh /

# Declare the exposed volumes
VOLUME /etc/sshsavedhostkeys
VOLUME /home/shelluser/.ssh

ENTRYPOINT ["/entrypoint.sh"]

# Post build you need to use docker-exec to add the public keys
#
# docker exec -it sshd  /addauthuser.sh "ssh-rsa AAAAB3Nz...GVVqApPd steve@slice.lan"
#

# To use the server:
# 
# start the server:
# docker run --name sshd \
# --detach \
# --publish 122:22 \
# --volume ~/path to your/sshsavedhostkeys:/etc/sshsavedhostkeys \
# --volume ~/path to your/authorized_keys:/home/shelluser/.ssh/authorized_keys \
#  ghcr.io/stevegroom/sshd:latest
#
# add your user id_rsa.pub to authorized_keys
# docker exec -it sshd /addauthuser.sh "$(cat ~/.ssh/id_rsa.pub )"
#
# ssh to your private host via this server
# ssh -J shelluser@exposed_dockerhost:122 youruser@private_address -p 22 
