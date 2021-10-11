#FROM adoptopenjdk/openjdk8:x86_64-debianslim-jdk8u302-b08-slim
#FROM adoptopenjdk/openjdk11:x86_64-ubuntu-jdk-11.0.12_7-slim

#Both Zeppelin and Spark have unsafe Java calls that are flagged in openjdk11
#FROM  adoptopenjdk/openjdk8-openj9:x86_64-ubuntu-jdk8u-nightly-slim

#FROM adoptopenjdk/openjdk8-openj9:x86_64-alpine-jdk8u302-b08_openj9-0.27.0

FROM adoptopenjdk/openjdk8:x86_64-debian-jdk8u302-b08

WORKDIR /

ARG HADOOP_VERSION
ENV HADOOP_VERSION=${HADOOP_VERSION:-3.3.1}

ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_CONF_DIR=/etc/hadoop

ENV HDFS_NAMENODE_USER=root
ENV HDFS_DATANODE_USER=root
ENV HDFS_SECONDARYNAMENODE_USER=root
ENV YARN_RESOURCEMANAGER_USER=root
ENV YARN_NODEMANAGER_USER=root

RUN apt update
RUN apt install -y wget curl ssh adduser net-tools procps nano
#addgroup usermod

#RUN addgroup hadoop
#RUN adduser --ingroup hadoop hadoop

WORKDIR /
#RUN wget -qO - https://archive.apache.org/dist/hadoop/core/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz
COPY bin/hadoop-${HADOOP_VERSION}.tar.gz /opt
RUN tar -xzf /opt/hadoop-${HADOOP_VERSION}.tar.gz -C /opt/

RUN mv /opt/hadoop-${HADOOP_VERSION} ${HADOOP_HOME}

ENV PATH=${PATH}:${HADOOP_HOME}/bin
ENV PATH=${PATH}:${HADOOP_HOME}/sbin

RUN mkdir -p ${HADOOP_CONF_DIR}
RUN mkdir -p ${HADOOP_CONF_DIR}/conf

COPY etc/* ${HADOOP_CONF_DIR}/
COPy etc/conf/* ${HADOOP_CONF_DIR}/conf/

RUN mkdir -p /metadata/dfs1/nn
RUN mkdir -p /metadata/dfs2/nn
RUN mkdir -p /metadata/dfs3/nn

RUN mkdir -p /data/dfs1/nn
RUN mkdir -p /data/dfs2/nn
RUN mkdir -p /data/dfs3/nn
RUN mkdir -p /data/dfs4/nn


RUN mkdir ~/.ssh
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
RUN cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
RUN chmod 0600 ~/.ssh/authorized_keys
RUN chmod 0600 /etc/ssh/ssh_host* # for default host key

RUN export JAVA_HOME
RUN echo "export JAVA_HOME=${JAVA_HOME}" > /etc/profile.d/java.sh
#RUN echo "export PATH=${JAVA_HOME}/bin:$PATH" >> /etc/profile.d/java.sh
RUN cat /etc/profile.d/java.sh >> /etc/environment

RUN echo "export PDSH_RCMD_TYPE=ssh" > /etc/profile.d/pdsh.sh

WORKDIR /
COPY scripts/hadoop-startup.sh /
RUN chmod +x hadoop-startup.sh

#ENTRYPOINT [ "/hadoop-startup.sh" ]
ENTRYPOINT [ "/bin/bash" ]
