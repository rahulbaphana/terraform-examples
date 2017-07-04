#!/bin/bash

sudo mkdir /var/spring-boot-app

sudo cp /tmp/spring-boot-hello-world-1.0-SNAPSHOT.jar /var/spring-boot-app/

sudo chmod 755 /var/spring-boot-app/spring-boot-hello-world-1.0-SNAPSHOT.jar

# create symlink
sudo ln -s /var/spring-boot-app/spring-boot-hello-world-1.0-SNAPSHOT.jar /etc/init.d/spring-boot-hello-world

sudo update-rc.d spring-boot-hello-world defaults
