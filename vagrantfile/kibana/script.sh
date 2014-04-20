#!/bin/bash

### OS
# iptables
service iptables stop
chkconfig iptables off

iptables -L

# timezone

rm -f /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

# limits.conf
cat <<EOS >> /etc/security/limits.conf

root soft nofile 65536
root hard nofile 65536
* soft nofile 65536
* hard nofile 65536
EOS

# cat /etc/security/limits.conf

# sysctl.conf
cat <<EOS >> /etc/sysctl.conf

net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 10240 65535
EOS

# cat /etc/sysctl.conf

### httpd
# Package
yum -y install httpd

# LogFormat
sed -i.bak '500a\LogFormat "%{%Y-%m-%d %T %Z}t %D %a %u [%r] %s %b [%{Referer}i] [%{User-Agent}i]" custom' /etc/httpd/conf/httpd.conf
sed -i.bak '501a\CustomLog logs/access_log custom' /etc/httpd/conf/httpd.conf

### Fluentd

# Package
yum -y install libcurl-devel
curl -L http://toolbelt.treasuredata.com/sh/install-redhat.sh | sh

# td-agent.conf
cat <<EOS >> /etc/td-agent/td-agent.conf

<source>
  type tail
  format apache
  path /var/log/httpd/access_log
  format /^(?<date>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} \w{3}) (?<processing_time>[^ ]*) (?<remote>[^ ]*) (?<user>[^ ]*) \[(?<method>.*)\] (?<status>[^ ]*) (?<size>[^ ]*) \[(?<referer>[^ ]*)\] \[(?<agent>.*)\]/
  pos_file /var/log/td-agent/kibana-apache-access.pos
  tag kibana.apache.access
</source>
 
<match kibana.apache.access>
  type elasticsearch
  include_tag_key true
  tag_key @log_name
  host localhost
  port 9200
  logstash_format true
  flush_interval 5s
</match>
EOS

# cat /etc/td-agent/td-agent.conf

# fluent-plugin-elasticsearch
/usr/lib64/fluent/ruby/bin/fluent-gem install --no-ri --no-rdoc fluent-plugin-elasticsearch

### Elasticsearch

# Package
yum -y install java-1.7.0-openjdk
rpm --import http://packages.elasticsearch.org/GPG-KEY-elasticsearch

# elasticsearch.repo
cat <<EOS > /etc/yum.repos.d/elasticsearch.repo
[elasticsearch-1.0]
name=Elasticsearch repository for 1.0.x packages
baseurl=http://packages.elasticsearch.org/elasticsearch/1.0/centos
gpgcheck=1
gpgkey=http://packages.elasticsearch.org/GPG-KEY-elasticsearch
enabled=1
EOS

yum -y install elasticsearch --enablerepo=elasticsearch-1.0

# marvel
/usr/share/elasticsearch/bin/plugin -i elasticsearch/marvel/latest

### kibana

# Package
wget https://download.elasticsearch.org/kibana/kibana/kibana-3.0.1.tar.gz

tar xzf kibana-3.0.1.tar.gz -C /var/www/html
rm -f kibana-3.0.1.tar.gz
ln -s /var/www/html/kibana-3.0.1 /var/www/html/kibana
ls -ld /var/www/html/kibana-3.0.1 /var/www/html/kibana

# config.js
perl -pi.bak -e 's/\"\+window.location.hostname\+\"/localhost/g' /var/www/html/kibana/config.js
# diff /var/www/html/kibana/config.js.bak /var/www/html/kibana/config.js

# cat /var/www/html/kibana/config.js

### Elasticsearch

# Service
chkconfig elasticsearch on
chkconfig elasticsearch --list

service elasticsearch start

### Fluentd

# Service
chkconfig td-agent on
chkconfig td-agent --list

service td-agent start

### httpd

# Service
chkconfig httpd on
chkconfig httpd --list

service httpd start

# Permission 
chmod -R 755 /var/log/httpd

### Service Status

service elasticsearch status
service td-agent status
service httpd status
