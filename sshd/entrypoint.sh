#!/bin/sh

echo "In sshd entrypoint.sh"
#echo "Turn on debug"
#set -x

# Generate any missing encryption keys for use by e.g. sshd 
# /etc/ssh/ssh_host* files 
# If these are recreated, the connection will fail due to mismatch in known_hosts.
# Mount it via the docker run command and then the same key can persist across builds...
# docker run --name sshd -d -p 122:22 --volume /home/steve/sshserver/sshd/.sshhostkeys:/etc/ <image>

# To keep host id: 
# check to see if /etc/sshsavedhostkeys has been mounted

# Restore server keys from backup
# If number of files in /etc/sshsavedhostkeys > 0 cp all in to /etc/ssh 
[  "$(ls -A /etc/sshsavedhostkeys 2>/dev/null)" > 0 ] && cp -rp /etc/sshsavedhostkeys/* /etc/ssh 

# Generate any missing server keys 
ssh-keygen -A

# Backup the server keys
# If sshsavedhostkeys exists then save the host keys
[ -d "/etc/sshsavedhostkeys" ] && cp -rp /etc/ssh/ssh_host* /etc/sshsavedhostkeys


# If shelluser has no private key, then set up .ssh folder, permissions and generate
# 
HOME=/home/shelluser
PRIVKEY=$HOME/.ssh/id_rsa

if [[ ! -f ${PRIVKEY} ]]
then
    mkdir -p $HOME/.ssh 
    chown -R shelluser:shelluser $HOME/.ssh
    chmod 700 $HOME/.ssh
    su shelluser -c "ssh-keygen -t rsa -q -f ${PRIVKEY} -N \"\" " 
fi

# https://linux.101hacks.com/unix/sshd/
# Using sshd -D to keep the daemon attached so that docker does not terminate
# -e option to send errors the log. 
exec /usr/sbin/sshd -D -e "$@"

