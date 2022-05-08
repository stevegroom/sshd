# SSH Server ( can be used as part of traefik ingress)

## Background

I use Traefik to control access to my home network. For security I use 
https with multifactor authentication and for ssh this dockerimage uses public key authentication - password based authentication is disabled.

I didn't want to disable password authentication on my existing ssh services, so have created a docker container that disables inbound connection password authentication that can be used as the traefik ingress point before hopping to other computers.

## Software

This dockerfile uses Alpine Linux to run an openssh server daemon. 

## Persistance

Two directories can optionally be exposed to the docker host system. Doing so will preserve the ssh servers host keys and the shell users ssh files. If you don't perist these directories, then you will have to trust the host id and re-add authorized keys every time the container is rebuilt.

| File or Folder | Description |
| -------------- | ----------- |
| ```/etc/sshsavedhostkeys``` | entrypoint.sh saves or restores this ssh server keys as needed|
| ```/home/shelluser/.ssh```  | shelluser - The jump user's .ssh folder containing the the PKI key, authorized_keys and known_hosts |

The image creates the sshd daemon's server keys in a mountable volume. This means that the container can be dropped, re-built, re-started without needing to issue and trust a new set of keys. 

# Quick command summary

## Rebuild

```bash
docker stop sshd;docker rm sshd;docker build --tag sshd .
```

## Start without persistance

```bash
docker run --name sshd --detach --port 122:22 sshd:latest
```

## Start with persistance

```bash
docker run --name sshd --detach --port 122:22 \
 --volume ~/sshserver/persist/sshsavedhostkeys:/etc/sshsavedhostkeys \
 --volume ~/sshserver/persist/authorized_keys:/home/shelluser/.ssh/authorized_keys \
 sshd:latest
```

## Add your public keys to the shelluser authorized_keys

```bash
docker exec -it sshd /addauthuser.sh "$(cat ~/.sshid_rsa.pub)"

-or-

docker exec -it sshd /addauthuser.sh "ssh-rsa AAAAB3NzaC ... your id_rsa.pub ...GVVqApPd steve@slice.lan"
```

## ssh into the jumpbox

```bash
ssh shelluser@dockerhost -p 122
```

## ssh through the jumpbox to private servers

```bash
ssh -J shelluser@dockerhost:122 user@privatehost -p 22
```

## Look inside the ssh server

```bash
docker exec -it sshd  /bin/sh
vi /etc/ssh/sshd_config
```

## Operations 

```bash
chmod 600 persist/authorized_keys

```

## Backup

To make a sharable backup - omit saving the keys:

```bash
tar -czvf sshserver.tar.gz --exclude sshserver/persist/shelluserssh/* --exclude sshserver/persist/sshsavedhostkeys/ sshserver 
```

# References

## Locking sshd to auth keys only 

https://techblog.thcb.org/how-to-install-openssh-server-on-alpine-linux-including-docker/ 

## Using sshd as a jump box 

Edit the sshd config file to allow port forwarding.

<https://www.ssh.com/academy/ssh/tunneling/example>
