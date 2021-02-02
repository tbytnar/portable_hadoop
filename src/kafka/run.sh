/bin/sh -c '/usr/share/kafka/bin/zookeeper-server-start.sh /usr/share/kafka/config/zookeeper.properties'

/bin/sh -c '/usr/share/kafka/bin/kafka-server-start.sh /usr/share/kafka/config/server.properties > /usr/share/kafka/kafka.log 2>&1'