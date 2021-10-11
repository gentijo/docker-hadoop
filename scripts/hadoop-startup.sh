#!/bin/bash

#service ssh start
/etc/rc3.d/S01ssh start
sleep 2

if [[ ! -f ~/.ssh/known_hosts ]]
then
  echo "Adding common keys to Known Hosts"
  ssh-keyscan `hostname` >> ~/.ssh/known_hosts
  ssh-keyscan 127.0.0.1 >> ~/.ssh/known_hosts
  ssh-keyscan localhost >> ~/.ssh/known_hosts
fi

hdfs namenode -format
/opt/hadoop/sbin/start-all.sh
