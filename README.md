# ubuntu-hadoop-hbase-dev
An image for ubuntu-18.04 + Hadoop 3.2.2 + HBase 2.3.5 + Java 8 (OpenJDK) Pseudo-Distributed ver.  
This image is based on [HariSekhon/Dockerfiles](https://github.com/HariSekhon/Dockerfiles).

## How to use
1. Dockerfiles  
`docker run -it -d -p 8088:8088 -p 9000:9000 -p 9870:9870 -p 16000:16000 -p 16010:16010 -p 16030:16030 -p 16201:16201 -p 16301:16301 -p 9090:9090 -p 9095:9095 -p 8080:8080 -p 8085:8085 -p 2181:2181 --name ubuntu-hadoop-hbase`

2. docker-compose  
`docker-compose -p server up -d`

3. DockerHub (pre-build)  
`docker run -it -d -p 8088:8088 -p 9000:9000 -p 9870:9870 -p 16000:16000 -p 16010:16010 -p 16030:16030 -p 16201:16201 -p 16301:16301 -p 9090:9090 -p 9095:9095 -p 8080:8080 -p 8085:8085 -p 2181:2181 --name ubuntu-hadoop-hbase guyleaf/ubuntu-hadoop-hbase-dev`
