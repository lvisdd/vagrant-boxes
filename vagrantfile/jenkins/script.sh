#!/bin/bash

### OS
# iptables
sed -i "/-A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT/a-A INPUT -m state --state NEW -m tcp -p tcp --dport 8080 -j ACCEPT" /etc/sysconfig/iptables
service iptables restart

### jenkins
# java
yum -y install java-1.7.0-openjdk.x86_64

# jenkins
wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key
yum -y install jenkins

# Service
chkconfig jenkins on
service jenkins start

sleep 10

# images
cp -p /vagrant/images/jenkins.png /var/cache/jenkins/war/images/jenkins.png
chown jenkins:jenkins /var/cache/jenkins/war/images/jenkins.png
chmod 644 /var/cache/jenkins/war/images/jenkins.png

# Service
service jenkins restart
