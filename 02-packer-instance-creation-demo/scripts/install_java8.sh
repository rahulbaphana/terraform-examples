#!/bin/bash

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y software-properties-common
sudo add-apt-repository ppa:webupd8team/java -y
sudo apt-get update
sudo echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
sudo apt-get install -y oracle-java8-installer
sudo apt-get clean

sudo echo 'JAVA_HOME=/usr/lib/jvm/java-8-oracle' >> sudo /etc/environment
