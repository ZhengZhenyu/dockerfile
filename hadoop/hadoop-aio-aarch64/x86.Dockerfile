FROM ubuntu:bionic

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY hadoop-3.4.0-SNAPSHOT.tar.gz /opt/

RUN apt-get -q update \
    && apt-get -q install -y --no-install-recommends \
        openssh-server \
        sudo \
        openjdk-8-jdk \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64


ARG BASEDIR=/opt
COPY hadoop-3.4.0-SNAPSHOT.tar.gz $BASEDIR
RUN cd $BASEDIR \
    && tar zxf hadoop-3.4.0-SNAPSHOT.tar.gz

ENV HADOOP_HOME $BASEDIR/hadoop-3.4.0-SNAPSHOT

RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa \
    && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys \
    && chmod 0600 ~/.ssh/authorized_keys

ENV PATH "${PATH}:$HADOOP_HOME/bin:$HADOOP_HOME/sbin"

RUN cp $HADOOP_HOME/etc/hadoop/core-site.xml{,-bak}
COPY core-site.xml $HADOOP_HOME/etc/hadoop/

RUN cp $HADOOP_HOME/etc/hadoop/hdfs-site.xml{,-bak}
COPY hdfs-site.xml $HADOOP_HOME/etc/hadoop/

RUN cp $HADOOP_HOME/etc/hadoop/mapred-site.xml{,-bak}
COPY mapred-site.xml $HADOOP_HOME/etc/hadoop/

RUN cp $HADOOP_HOME/etc/hadoop/yarn-site.xml{,-bak}
COPY yarn-site.xml $HADOOP_HOME/etc/hadoop/

RUN useradd -m -d /home/hadoop -s /bin/bash hadoop && echo hadoop:hadoop | chpasswd && adduser hadoop sudo
RUN echo "hadoop ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN chown hadoop.hadoop $HADOOP_HOME -R

USER hadoop
WORKDIR $HADOOP_HOME

## I have no idea about this
#RUN echo "export JAVA_HOME=${JAVA_HOME}" >> /home/hadoop/hadoop-3.4.0-SNAPSHOT/etc/hadoop/hadoop-env.sh
#
#RUN mkdir -p /tmp/hadoop-terasort/
#
#EXPOSE 8088
#
#COPY entrypoint.sh /home/hadoop/
#
#ENTRYPOINT ["/home/hadoop/entrypoint.sh"]

# NOTE: need to specify the num of GB zise of data for terasort, e.g.
# docker run -p 8088:8088 --name hadoop-terasort-1 -d liusheng2048/hadoop-terasort-x86 5
# docker logs hadoop-terasort-1
