#!/bin/bash
set -e
H=/home/pablo
# volume montado vazio: copia o esqueleto
[ -e $H/.zshrc ] || cp -a /home/pablo.skel/. $H/
mkdir -p $H/.ssh $H/.sshd
[ -f $H/.sshd/ssh_host_ed25519_key ] || ssh-keygen -q -t ed25519 -N '' -f $H/.sshd/ssh_host_ed25519_key
if [ -n "$SSH_PUBLIC_KEY" ]; then echo "$SSH_PUBLIC_KEY" > $H/.ssh/authorized_keys; fi
chown -R pablo:pablo $H
chmod 700 $H/.ssh $H/.sshd; chmod 600 $H/.ssh/authorized_keys $H/.sshd/ssh_host_ed25519_key
exec /usr/bin/sshd -D -e
