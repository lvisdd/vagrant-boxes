#!/bin/bash

### OS
# iptables
iptables -F

service iptables stop
chkconfig iptables off

service ip6tables stop
chkconfig ip6tables off

iptables -L

### R
# epel
rpm -ivh http://ftp.riken.jp/Linux/fedora/epel/6/x86_64/epel-release-6-8.noarch.rpm

# R
yum -y install R

### rstudio
# rstudio
yum -y install openssl098e
yum -y install compat-libgfortran-41
yum -y install gstreamer-plugins-base

rpm -ivh http://download2.rstudio.org/rstudio-server-0.98.944-x86_64.rpm

# service
cp -p /usr/lib/rstudio-server/extras/init.d/redhat/rstudio-server /etc/init.d/
rstudio-server verify-installation
# rstudio-server start

chkconfig rstudio-server on
chkconfig --list rstudio-server