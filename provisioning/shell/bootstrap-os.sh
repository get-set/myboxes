#!/bin/bash

# Common envirenment virables
PASSWORD=${1:-"root"}
APT_MIRROR_HOST="mirrors.aliyun.com"
PYPI_MIRROR_URL="https://pypi.tuna.tsinghua.edu.cn/simple"

# Change password for root and permit root login
sudo -s << EOF

(echo "$PASSWORD";sleep 1;echo "$PASSWORD") | passwd root &> /dev/null

rm -f /etc/localtime; ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# Change to domestic repo mirror (no need for centos now)
which yum &> /dev/null && \
    rm -f /etc/yum.repos.d/epel* && \
    wget -qO /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo && \
    rm -f /etc/yum.repos.d/ius* && \
    wget -qO /etc/yum.repos.d/ius.repo http://mirrors.aliyun.com/ius/ius-7.repo && \
    yum makecache && \
    echo "Installing packages: $2 ..." && \
    yum install -y vim $2 > /dev/null
which apt &> /dev/null && \
    cp /etc/apt/sources.list /etc/apt/sources.list.bk && \
    sed -i 's/archive.ubuntu.com/${APT_MIRROR_HOST}/g;s/security.ubuntu.com/${APT_MIRROR_HOST}/g' /etc/apt/sources.list && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    echo "Installing packages: $2 ..." && \
    apt-get -qq install -y $2 > /dev/null

# Disable selinux
cat /etc/issue | grep -qi "centos" && sed -i '/^SELINUX=/c SELINUX=disabled' /etc/selinux/config && setenforce 0


# Use Domestic pypi mirror
echo -e "[global]\nindex-url = ${PYPI_MIRROR_URL}" > /etc/pip.conf

# Set English Locale
echo "LANG=en_US.utf-8" >> /etc/environment
echo "LC_ALL=en_US.utf-8" >> /etc/environment
echo "HOST_PROXY=$3" >> /etc/environment

EOF
