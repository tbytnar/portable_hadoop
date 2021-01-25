docker build --pull --rm -f  "src\hadoop-base\Dockerfile" -t tbytnar/portable-hadoop:hadoop-base "src\hadoop-base"
docker push tbytnar/portable-hadoop:hadoop-base
docker build --pull --rm -f "src\datanode\Dockerfile" -t tbytnar/portable-hadoop:hadoop-datanode "src\datanode"
docker build --pull --rm -f "src\historyserver\Dockerfile" -t tbytnar/portable-hadoop:hadoop-historyserver "src\historyserver"
docker build --pull --rm -f "src\namenode\Dockerfile" -t tbytnar/portable-hadoop:hadoop-namenode "src\namenode"
docker build --pull --rm -f "src\nodemanager\Dockerfile" -t tbytnar/portable-hadoop:hadoop-nodemanager "src\nodemanager"
docker build --pull --rm -f "src\resourcemanager\Dockerfile" -t tbytnar/portable-hadoop:hadoop-resourcemanager "src\resourcemanager"

docker build --pull --rm -f "src\hive-base\Dockerfile" -t tbytnar/portable-hadoop:hive-base "src\hive-base"
docker push tbytnar/portable-hadoop:hive-base
docker build --pull --rm -f "src\hiveserver\Dockerfile" -t tbytnar/portable-hadoop:hadoop-hiveserver "src\hiveserver"
docker build --pull --rm -f "src\hive-metastore\Dockerfile" -t tbytnar/portable-hadoop:hive-metastore "src\hive-metastore"

docker build --pull --rm -f  "src\spark-base\Dockerfile" -t tbytnar/portable-hadoop:spark-base "src\spark-base"
docker push tbytnar/portable-hadoop:spark-base
docker build --pull --rm -f  "src\spark-master\Dockerfile" -t tbytnar/portable-hadoop:spark-master "src\spark-master"
docker build --pull --rm -f  "src\spark-worker\Dockerfile" -t tbytnar/portable-hadoop:spark-worker "src\spark-worker"

docker build --pull --rm -f "src\client\Dockerfile" -t tbytnar/portable-hadoop:client .
docker push tbytnar/portable-hadoop:client