#!/bin/sh

set -o errexit

exec > /root/configure.log 2>&1

yum -y upgrade

yum -y install \
	xrdp \
	firefox \
	@gnome-desktop
#@development-tools \

curl -sfL -o code.rpm 'https://code.visualstudio.com/sha/download?build=stable&os=linux-rpm-x64'
yum -y localinstall code.rpm
rm code.rpm

yum clean all

systemctl enable xrdp

# Guacamole only supports rdp security
sed -i '/^security.layer=/ s/=.*/=rdp/' /etc/xrdp/xrdp.ini

# Guacamole only supports ssh-rsa
cat > /etc/ssh/sshd_config.d/10-override-crypto-policies.conf <<EOF
HostKeyAlgorithms=+ssh-rsa,ssh-dss
PubkeyAcceptedAlgorithms=+ssh-rsa,ssh-dss
EOF

# shellcheck disable=2174
mkdir -m 700 -p /root/.ssh
curl -sf https://github.com/larsks.keys https://github.com/naved001.keys > /root/.ssh/authorized_keys
chown 400 /root/.ssh/authorized_keys
