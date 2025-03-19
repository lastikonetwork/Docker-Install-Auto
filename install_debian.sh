#!/bin/bash

# Cek 64-bit dan Debian 11 atau Debian 12
if [ "$(uname -m)" != "x86_64" ] || ! (grep -q 'Debian GNU/Linux 11' /etc/os-release || grep -q 'Debian GNU/Linux 12' /etc/os-release); then
    echo "Using Only On Linux Ubuntu 64-bit."
    exit 1
fi

# Cek root
if [ "$(id -u)" -ne 0 ]; then
    echo "Running on root."
    exit 1
fi

# Update package index
apt-get update
apt-get install -y ca-certificates curl gnupg

# Tambahkan GPG key resmi Docker
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Tambahkan repository Docker
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list
apt-get update

# Instal Docker
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Tambahkan grup Docker jika belum ada
if ! getent group docker > /dev/null; then
    groupadd docker
fi

# Tambahkan pengguna saat ini ke grup Docker
usermod -aG docker $USER

# Informasikan kepada pengguna untuk logout dan login kembali agar perubahan grup berlaku
echo "For using the docker please logout then login again."

# Aktifkan auto start Docker
systemctl enable docker.service
systemctl enable containerd.service

# Pesan penutup
echo "Docker Install Successfully."
