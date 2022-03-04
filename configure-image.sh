#!/bin/sh

set -o errexit

exec > /root/configure.log 2>&1

# It looks like kernel ugprades done inside the libguestfs environment
# result in an unbootable image, so we exclude kernel packages from the
# upgrade.
yum -y upgrade -x 'kernel' -x 'kernel-*'

yum -y install \
	xrdp \
	firefox \
	@gnome-desktop \
	@development-tools

systemctl enable xrdp

curl -sfL -o code.rpm 'https://code.visualstudio.com/sha/download?build=stable&os=linux-rpm-x64'
yum -y localinstall code.rpm
rm code.rpm

yum clean all

# Guacamole only supports rdp security
if [ -f /etc/xrdp/xrdp.ini ]; then
	sed -i '/^security.layer=/ s/=.*/=rdp/' /etc/xrdp/xrdp.ini
fi

# Guacamole only supports ssh-rsa
cat > /etc/ssh/sshd_config.d/10-override-crypto-policies.conf <<EOF
HostKeyAlgorithms=+ssh-rsa,ssh-dss
PubkeyAcceptedAlgorithms=+ssh-rsa,ssh-dss
EOF

# shellcheck disable=2174
mkdir -m 700 -p /root/.ssh
curl -sf https://github.com/larsks.keys https://github.com/naved001.keys > /root/.ssh/authorized_keys
chown 400 /root/.ssh/authorized_keys
