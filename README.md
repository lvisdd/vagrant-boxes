# Vagrant Base Boxes

## Environment

* Windows7 (SP1 64Bit)
* [veewee](https://github.com/jedi4ever/veewee) (0.3.12)
* [Vagrant](http://www.vagrantup.com/downloads.html) (1.5.3)
* [VirtualBox](https://www.virtualbox.org/wiki/Downloads) (4.3.10)

## Downloads

* **[CentOS-6.5-x86_64-v20140420.box](https://box.yahoo.co.jp/guest/viewer?sid=box-l-cvykn4mdamxapug64lffi2qc5u-1001&uniqid=40f6455f-fdf5-403f-9d1d-86665268568f&viewtype=detail):** CentOS 6.5 x86\_64 Minimal *(Vagrant 1.5.3, VirtualBox Guest Additions 4.3.10, Chef 11.12.2, Puppet 3.5.1)*  
  <small>md5sum: `cdeacfcdce1d58103dc2867a639ebe21`</small>

## How to build these boxes

```sh

### Install veewee
$ git clone git://github.com/jedi4ever/veewee.git
$ cd veewee
$ bundle install
$ bundle exec veewee version

# Version : 0.3.12

$ bundle exec veewee vbox templates
$ bundle exec veewee vbox define CentOS-6.5-x86_64 CentOS-6.5-x86_64-minimal

# Edit definitions\CentOS-6.5-x86_64\ks.cfg
# Edit definitions\CentOS-6.5-x86_64\definition.rb

### Build
$ bundle exec veewee vbox build CentOS-6.5-x86_64

### Eject the disks from the running VM.

### Shutdown
$ ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p 7222 -l veewee 127.0.0.1

# password: veewee

sudo shutdown -h now

### Output BOX
$ bundle exec vagrant package --base CentOS-6.5-x86_64 --output CentOS-6.5-x86_64-v20140420.box

$ md5sum CentOS-6.5-x86_64-v20140420.box

# cdeacfcdce1d58103dc2867a639ebe21 *CentOS-6.5-x86_64-v20140420.box

```

## How to use these Vagrantfiles

### Fluentd + Elasticsearch + kibana

```sh

$ git clone https://github.com/lvisdd/vagrant-boxes.git
$ cd vagrant-boxes/vagrantfile/kibana
$ vagrant up

```

## Browsing Test
* Apache : http://localhost:8080/
* Elasticsearch : http://localhost:9200/
* Kibana : http://localhost:8080/kibana/#/dashboard
* Kibana(Logstash Dashboard) : http://localhost:8080/kibana/index.html#/dashboard/file/logstash.json
* Marvel : http://localhost:9200/_plugin/marvel/kibana/index.html#/dashboard/file/marvel.overview.json
* sense : http://localhost:9200/_plugin/marvel/sense/index.html

## Apache Bench Test

```sh

$ ab -n 1000 -c 100 http://localhost/

```
