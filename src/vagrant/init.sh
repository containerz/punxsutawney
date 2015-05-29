#!/bin/bash

# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

install_mesos() {
    mode=$1 # master | slave
    apt-get -qy install mesos

    echo "zk://master:2181/mesos" > /etc/mesos/zk

    ip=$(cat /etc/hosts | grep `hostname` | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}")
    echo $ip > "/etc/mesos-$mode/ip"

    if [ $mode == "master" ]; then
        ln -s /lib/init/upstart-job /etc/init.d/mesos-master
        service mesos-master start
    else
        apt-get -qy remove zookeeper
    fi

    ln -s /lib/init/upstart-job /etc/init.d/mesos-slave
    service mesos-slave start
}

install_marathon() {
    apt-get install -qy marathon
    service marathon start
}

install_kafka() {
    pushd /opt/
    wget http://www.us.apache.org/dist/kafka/0.8.2.1/kafka_2.11-0.8.2.1.tgz
    tar -xf kafka*.tgz
    rm kafka*.tgz

    sed -i "2i export KAFKA_HEAP_OPTS=\"-Xmx128m -Xms128m\"" kafka*/bin/kafka-server-start.sh
    popd

    cp kafka /etc/init.d
    update-rc.d kafka defaults
    service kafka start
}

if [[ $1 != "master" && $1 != "slave" ]]; then
    echo "Usage: $0 master|slave"
    exit 1
fi
mode=$1

cd /vagrant/src/vagrant

# name resolution
cp .vagrant/hosts /etc/hosts

# ssh key
key=".vagrant/ssh_key.pub"
if [ -f $key ]; then
    cat $key >> /home/vagrant/.ssh/authorized_keys
fi

# disable ipv6
echo -e "\nnet.ipv6.conf.all.disable_ipv6 = 1\n" >> /etc/sysctl.conf
sysctl -p

# use apt-proxy if present
if [ -f ".vagrant/apt-proxy" ]; then
    apt_proxy=$(cat ".vagrant/apt-proxy")
    echo "Using apt-proxy: $apt_proxy";
    echo "Acquire::http::Proxy \"$apt_proxy\";" > /etc/apt/apt.conf.d/90-apt-proxy.conf
fi

# add mesosphere repo
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E56151BF
DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
CODENAME=$(lsb_release -cs)
echo "deb http://repos.mesosphere.io/${DISTRO} ${CODENAME} main" | tee /etc/apt/sources.list.d/mesosphere.list

apt-get -qy update

# install deps
apt-get install -qy vim zip mc curl wget openjdk-7-jre scala git

install_mesos $mode
if [ $mode == "master" ]; then
    install_marathon;
    install_kafka
fi

