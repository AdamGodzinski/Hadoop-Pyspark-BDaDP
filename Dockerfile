FROM ubuntu:18.04

WORKDIR /root

EXPOSE 50070 50075 50010 50020 50090 8020 9000 9864 9870 10020 19888 8088 8030 8031 8032 8033 8040 8042 22

RUN apt-get update && apt-get install -y openssh-server openjdk-11-jdk wget

RUN wget https://archive.apache.org/dist/hadoop/common/hadoop-3.3.4/hadoop-3.3.4.tar.gz && \
    tar -xzvf hadoop-3.3.4.tar.gz && \
    mv hadoop-3.3.4 /usr/local/hadoop && \
    rm hadoop-3.3.4.tar.gz

RUN wget https://archive.apache.org/dist/spark/spark-3.3.2/spark-3.3.2-bin-without-hadoop.tgz && \
    tar xvf spark-3.3.2-bin-without-hadoop.tgz && \
    mv spark-3.3.2-bin-without-hadoop /usr/local/spark && \
    rm spark-3.3.2-bin-without-hadoop.tgz


RUN apt update --yes && \
    apt install python3 --yes &&\
    apt install python3-pip --yes

RUN pip3 install --upgrade pip

RUN pip3 install notebook 
#RUN pip3 install virtualenv

RUN pip3 install pyspark

#RUN mkdir py_env

#RUN virualenv py_env && \
#    source py_env/bin/activate

ENV JUPYTER_PORT=8888
EXPOSE $JUPYTER_PORT

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV HADOOP_HOME=/usr/local/hadoop
ENV PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin:/usr/local/spark/bin
ENV SPARK_HOME=/usr/local/spark
ENV PYTHONPATH=/usr/bin/python3


RUN mkdir -p ~/hdfs/namenode && \
    mkdir -p ~/hdfs/datanode && \
    mkdir $HADOOP_HOME/logs

# ssh without key
RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

COPY config/* /tmp/

RUN mv /tmp/ssh_config ~/.ssh/config && \
    mv /tmp/hadoop-env.sh /usr/local/hadoop/etc/hadoop/hadoop-env.sh && \
    mv /tmp/workers $HADOOP_HOME/etc/hadoop/slaves && \
    mv /tmp/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \
    mv /tmp/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml && \
    mv /tmp/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml && \
    mv /tmp/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    mv /tmp/spark-env.sh /usr/local/spark/conf

RUN /usr/local/hadoop/bin/hdfs namenode -format

CMD [ "sh", "-c", "service ssh start; bash"]

