#!/bin/bash

### OS
# iptables
iptables -F

service iptables stop
chkconfig iptables off

iptables -L

### docker
# epel
rpm -ivh http://ftp.riken.jp/Linux/fedora/epel/6/i386/epel-release-6-8.noarch.rpm

# docker
yum install -y docker-io
chkconfig docker on
service docker start
