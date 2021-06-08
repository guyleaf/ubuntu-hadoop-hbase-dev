#!/usr/bin/env bash

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x

export JAVA_HOME="${JAVA_HOME:-/usr}"
export HADOOP_HOME=/hadoop
export HBASE_HOME=/hbase

source $HADOOP_HOME/etc/hadoop/hadoop-env.sh

user="root"

if ! [ -f "$user/.ssh/id_rsa" ]; then
    su - "$user" <<-EOF
        [ -n "${DEBUG:-}" ] && set -x
        ssh-keygen -t rsa -f ~/.ssh/id_rsa -N ""
EOF
fi

if ! [ -f "$user/.ssh/authorized_keys" ]; then
    su - "$user" <<-EOF
        [ -n "${DEBUG:-}" ] && set -x
        cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
EOF
fi

if ! pgrep -x sshd &>/dev/null; then
    su - "$user" <<-EOF
            [ -n "${DEBUG:-}" ] && set -x
            /etc/init.d/ssh start
EOF
fi
echo
SECONDS=0
while true; do
    if ! ssh-keyscan localhost 2>&1 | grep -q OpenSSH; then
        echo "SSH is ready to rock"
        break
    fi
    if [ "$SECONDS" -gt 20 ]; then
        echo "FAILED: SSH failed to come up after 20 secs"
        exit 1
    fi
    echo "waiting for SSH to come up"
    sleep 1
done
echo
if ! [ -f /root/.ssh/known_hosts ]; then
    ssh-keyscan localhost || :
    ssh-keyscan 0.0.0.0   || :
fi | tee -a /root/.ssh/known_hosts

hostname="$(hostname -f)"

if grep -q "$hostname" /root/.ssh/known_hosts; then
    ssh-keyscan "$hostname" || :
fi | tee -a /root/.ssh/known_hosts

mkdir -pv "$HADOOP_HOME/logs"
mkdir -pv "$HBASE_HOME/logs"

bash start-all.sh

source $HBASE_HOME/conf/hbase-env.sh

bash start-hbase.sh

jps

trap 'trap - INT; kill "$!"; exit' INT
exec tail -f /dev/null "$HADOOP_HOME/logs/"* & tail -f /dev/null "$HBASE_HOME/logs/"* & wait $!

bash stop-all.sh
bash stop-hbase.sh
