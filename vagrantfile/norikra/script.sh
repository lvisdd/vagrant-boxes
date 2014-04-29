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

echo ok | tee /var/www/html/index.html

### Fluentd

# Package
yum -y install libcurl-devel
curl -L http://toolbelt.treasuredata.com/sh/install-redhat.sh | sh

# td-agent.conf

chmod a+rx /var/log/httpd
mkdir /etc/td-agent/pos
chown td-agent:td-agent /etc/td-agent/pos

cat <<EOS > /etc/td-agent/td-agent.conf

<source>
  type tail
  format /^(?<host>[^ ]*) [^ ]* (?<user>[^ ]*) \[(?<time>[^\]]*)\] "(?<method>\S+)(?: +(?<path>[^ ]*) +\S*)?" (?<code>[^ ]*) (?<size>[^ ]*)(?: "(?<referer>[^\"]*)" "(?<agent>[^\"]*)")?$/
  time_format %d/%b/%Y:%H:%M:%S %z
  path /var/log/httpd/access_log
  tag apache.access
  pos_file /etc/td-agent/pos/apache.access_log
</source>
 
<match apache.access>
  type    norikra
  norikra localhost:26571
 
  remove_tag_prefix apache
  target_map_tag    true
</match>
EOS

# cat /etc/td-agent/td-agent.conf

### Norikra
# rbenv
yum -y install git gcc-c++
git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
# exec $SHELL -l
source ~/.bash_profile
# rbenv --version

# jruby
yum -y install java-1.7.0-openjdk.x86_64
git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
# rbenv install -l | grep jruby

rbenv install jruby-1.7.9
rbenv shell jruby-1.7.9
ruby -v

rbenv global jruby-1.7.9

# norikra
gem install norikra --no-ri --no-rdoc
rbenv rehash

which norikra
gem list --local | grep norikra

mkdir /{etc,var/log,var/run}/norikra
# chown ec2-user:ec2-user /{etc,var/log,var/run}/norikra/

# /etc/norikra/norikra.json
cat <<EOS > /etc/norikra/norikra.json
{
  "targets": [
    {
      "name": "access",
      "fields": {
        "host": {
          "name": "host",
          "type": "string",
          "optional": false
        },
        "user": {
          "name": "user",
          "type": "string",
          "optional": false
        },
        "method": {
          "name": "method",
          "type": "string",
          "optional": false
        },
        "path": {
          "name": "path",
          "type": "string",
          "optional": false
        },
        "code": {
          "name": "code",
          "type": "string",
          "optional": false
        },
        "size": {
          "name": "size",
          "type": "string",
          "optional": false
        },
        "referer": {
          "name": "referer",
          "type": "string",
          "optional": false
        },
        "agent": {
          "name": "agent",
          "type": "string",
          "optional": false
        }
      },
      "auto_field": true
    }
  ],
  "queries": [
    {
      "name": "access_count_per_1min",
      "group": null,
      "expression": "SELECT host, COUNT(*) FROM access.win:time_batch(1 min) GROUP BY host"
    },
    {
      "name": "access_over_1000_per_1min",
      "group": null,
      "expression": "SELECT host, COUNT(*) as requests FROM access.win:time_batch(1 min) GROUP BY host HAVING COUNT(*) >= 1000"
    }
  ]
}
EOS

# fluent-plugin-norikra
/usr/lib64/fluent/ruby/bin/fluent-gem install fluent-plugin-norikra --no-ri --no-rdoc

### norikra
norikra start --stats=/etc/norikra/norikra.json -l /var/log/norikra --daemonize
sleep 60

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
service td-agent status
service httpd status

### Browsing Test
curl http://localhost:26578/

### Apache Bench Test
# ab -c 5 -n 100 http://localhost/index.html;sleep 80;ab -c 5 -n 200 http://localhost/index.html
# sleep 60
# norikra-client event fetch access_count_per_1min
# 
# ab -c 5 -n 1000 http://localhost/index.html
# sleep 60
# norikra-client event fetch access_over_1000_per_1min
