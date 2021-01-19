docker build --pull --rm -f  "src\hadoop-base\Dockerfile" -t tbytnar/portable-hadoop:hadoop-base "src\hadoop-base"
docker push tbytnar/portable-hadoop:hadoop-base
docker build --no-cache --pull --rm -f "src\datanode\Dockerfile" -t tbytnar/portable-hadoop:hadoop-datanode "src\datanode"
docker build --no-cache --pull --rm -f "src\historyserver\Dockerfile" -t tbytnar/portable-hadoop:hadoop-historyserver "src\historyserver"
docker build --no-cache --pull --rm -f "src\namenode\Dockerfile" -t tbytnar/portable-hadoop:hadoop-namenode "src\namenode"
docker build --no-cache --pull --rm -f "src\nodemanager\Dockerfile" -t tbytnar/portable-hadoop:hadoop-nodemanager "src\nodemanager"
docker build --no-cache --pull --rm -f "src\resourcemanager\Dockerfile" -t tbytnar/portable-hadoop:hadoop-resourcemanager "src\resourcemanager"
docker build --no-cache --pull --rm -f "src\hive-base\Dockerfile" -t tbytnar/portable-hadoop:hive-base "src\hive-base"
docker push tbytnar/portable-hadoop:hive-base
docker build --no-cache --pull --rm -f "src\hiveserver\Dockerfile" -t tbytnar/portable-hadoop:hadoop-hiveserver "src\hiveserver"
docker build --no-cache --pull --rm -f "src\hive-metastore\Dockerfile" -t tbytnar/portable-hadoop:hive-metastore "src\hive-metastore"


docker build --no-cache --pull --rm -f "src\client\Dockerfile" -t tbytnar/portable-hadoop:client .