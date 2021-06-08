#!/usr/bin/env bash

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x

echo -e "export JAVA_HOME=${JAVA_HOME:-/usr}\n\
export PATH=$PATH:/hadoop/sbin:/hadoop/bin\n\
export HADOOP_HOME=/hadoop" >> /hadoop/etc/hadoop/hadoop-env.sh

echo -e "export JAVA_HOME=${JAVA_HOME:-/usr}\n\
export PATH=$PATH:/hbase/bin\n\
export HBASE_HOME=/hbase\n\
export HBASE_CLASSPATH=/hadoop/etc/hadoop\n\
export HBASE_MANAGES_ZK=true" >> /hbase/conf/hbase-env.sh

echo
