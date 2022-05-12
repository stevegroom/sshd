#!/bin/sh
# Append a id_rsa.pub key to the container's /home/shelluser/.ssh/authorized_keys 

echo "Utility to add passed public key to the authorized_keys"

[  -z "$1" ] && echo "Usage: addauthuser.sh <pubkey>" && exit

ssh-keygen -l -f <(echo $1) 2> /dev/null|| echo "Bad key - not added" || exit 1

echo "Adding:"
ssh-keygen -l -f <(echo $1)
echo $1 >>/home/shelluser/.ssh/authorized_keys
echo "to authorized_keys:"
echo "All authorized keys are"
ssh-keygen -l -f /home/shelluser/.ssh/authorized_keys

exit