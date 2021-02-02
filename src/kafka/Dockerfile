FROM ubuntu:bionic

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    openjdk-8-jdk \
    net-tools \
    curl \
    wget \
    netcat \
    sudo 

ENV KAFKA_VERSION 2.7.0
ENV KAFKA_URL https://downloads.apache.org/kafka/$KAFKA_VERSION/kafka_2.13-$KAFKA_VERSION.tgz

RUN wget $KAFKA_URL -O /tmp/kafka.tgz && mkdir /usr/share/kafka && tar -xvzf /tmp/kafka.tgz -C /usr/share/kafka/ --strip 1 

ADD entrypoint.sh /entrypoint.sh
ADD run.sh /run.sh
RUN chmod a+x /entrypoint.sh && chmod a+x /run.sh

CMD ["/run.sh"]
ENTRYPOINT ["/entrypoint.sh"]