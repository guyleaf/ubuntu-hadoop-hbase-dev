#
#  Author: GuyLeaf
#  Date: 2021-06-29 23:35:57 GMT+08
#

FROM guyleaf/ubuntu-java-bionic:latest
LABEL AUTHOR "GuyLeaf (https://github.com/guyleaf)"

ARG HADOOP_VERSION=3.2.2
ARG HBASE_VERSION=2.3.5

ARG HBASE_TARGET=hbase-${HBASE_VERSION}-bin.tar.gz
ARG HADOOP_TARGET=hadoop-${HADOOP_VERSION}.tar.gz

ENV PATH $PATH:/hadoop/bin:/hbase/bin

LABEL Description="Hadoop Pseudo-Distributed" \
        "Hadoop Version"="$HADOOP_VERSION" \
        "Hbase Version"="$HBASE_VERSION"

WORKDIR /

RUN set -eux && apt-get update

RUN set -eux && apt-get upgrade -y

RUN set -eux && \
    apt-get install -y openssh-server openssh-client tar && apt-get clean

RUN set -eux && wget --retry-connrefused "https://downloads.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/$HADOOP_TARGET" && \
    mkdir "hadoop" && tar zxf "$HADOOP_TARGET" -C "hadoop" --strip 1 && test -d "hadoop" && \
    rm -fv "$HADOOP_TARGET"

RUN set -eux && wget --retry-connrefused "https://downloads.apache.org/hbase/${HBASE_VERSION}/$HBASE_TARGET" && \
    mkdir "hbase" && tar zxf "$HBASE_TARGET" -C "hbase" --strip 1 && test -d "hbase" && \
    rm -fv "$HBASE_TARGET"

COPY hadoop-hbase/entrypoint.sh /
COPY hadoop-hbase/setting.sh /
COPY hadoop-hbase/conf/core-site.xml /hadoop/etc/hadoop/
COPY hadoop-hbase/conf/hdfs-site.xml /hadoop/etc/hadoop/
COPY hadoop-hbase/conf/yarn-site.xml /hadoop/etc/hadoop/
COPY hadoop-hbase/conf/mapred-site.xml /hadoop/etc/hadoop/
COPY hadoop-hbase/conf/hbase-site.xml /hbase/conf/

RUN set -eux && \
    mkdir -p /hdfs/name && \
    mkdir -p /hdfs/data && \
    mkdir -p /hadoop/logs && \
    chmod -R 0770 /hadoop/logs && \
    # Hadoop 3.x
    /hadoop/bin/hdfs namenode -format && \
    mkdir -p /root/.ssh && \
    chmod 0700 /root/.ssh

RUN chmod +x /entrypoint.sh
RUN chmod +x /setting.sh

RUN /setting.sh
RUN set -eux && rm /setting.sh

ENV HDFS_NAMENODE_USER=root
ENV HDFS_SECONDARYNAMENODE_USER=root
ENV HDFS_DATANODE_USER=root
ENV YARN_RESOURCEMANAGER_USER=root
ENV YARN_NODEMANAGER_USER=root

# HADOOP 3.x
EXPOSE 8088 9000 9870

# Stargate  8080  / 8085
# Thrift    9090  / 9095
# HMaster   16000 / 16010
# RS        16201 / 16301
EXPOSE 2181 8080 8085 9090 9095 16000 16010 16030 16201 16301

CMD ["/entrypoint.sh"]
