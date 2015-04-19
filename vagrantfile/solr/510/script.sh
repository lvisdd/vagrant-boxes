#!/bin/bash

### OS
# iptables
# sed -i "/-A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT/a-A INPUT -m state --state NEW -m tcp -p tcp --dport 8080 -j ACCEPT" /etc/sysconfig/iptables
sed -i "/-A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT/a-A INPUT -m state --state NEW -m tcp -p tcp --dport 8983 -j ACCEPT" /etc/sysconfig/iptables
service iptables restart

### solr
# utility
yum -y install unzip

# java
yum -y install java-1.7.0-openjdk.x86_64

# solr
cd /var/tmp
wget http://ftp.riken.jp/net/apache/lucene/solr/5.1.0/solr-5.1.0.tgz
tar xzvf solr-5.1.0.tgz
cd solr-5.1.0
./bin/install_solr_service.sh ../solr-5.1.0.tgz -d /opt/solr

rm -fR /var/tmp/solr-5.1.0*

service solr stop
service solr status

### Core (sample)
cd /opt/solr
mkdir -p /opt/solr/data/sample
cp -rp server/solr/configsets/sample_techproducts_configs/conf/ /opt/solr/data/sample/
mkdir -p /opt/solr/data/sample/data
chmod -R a+w /opt/solr/data/sample/data

cat <<EOS > /opt/solr/data/sample/core.properties
name=sample
config=solrconfig.xml
schema=schema.xml
dataDir=data
EOS

chown -R solr:solr /opt/solr /opt/solr-5.1.0

### Service
service solr start
sleep 30
service solr status

### Browser
# http://localhost:8983/solr/admin
# http://localhost:8983/solr/#/sample/query

### Indexing Data
# For more information, See.
# http://lucene.apache.org/solr/quickstart.html

cd /opt/solr

## Indexing a directory of "rich" files
# bin/post -c sample docs/

## Indexing Solr XML
bin/post -c sample example/exampledocs/*.xml

## Indexing JSON
# bin/post -c sample example/exampledocs/*.json

## Indexing CSV (Comma/Column Separated Values)
# bin/post -c sample example/exampledocs/*.csv

## Deleting Data
# bin/post -c sample -d "<delete><query>*:*</query></delete>"

## Searching
# http://localhost:8983/solr/sample/select?q=*:*&wt=json&indent=true
curl "http://localhost:8983/solr/sample/select?q=*:*&wt=json&indent=true"
