#!/bin/bash

# Set some sensible defaults
export CORE_CONF_fs_defaultFS=${CORE_CONF_fs_defaultFS:-hdfs://`hostname -f`:8020}

function addProperty() {
  local path=$1
  local name=$2
  local value=$3
  local type=$4

    if [ ! -f "$path" ]; then
        echo "$path is missing.  Creating from template."
        local template_path="$path.template"
        cp $template_path $path
    fi

    if [ "$type" = "xml" ];
    then
        local entry="<property><name>$name</name><value>${value}</value></property>"
        local escapedEntry=$(echo $entry | sed 's/\//\\\//g')
        sed -i "/<\/configuration>/ s/.*/${escapedEntry}\n&/" $path
    elif [ "$type" = "txt" ];
    then
        local entry="$name=$value"
        echo $entry >> $path
    else
        echo "Unknown file type ${type} supplied.  Please try again."
    fi
    
}

function configure() {
    local path=$1
    local module=$2
    local envPrefix=$3
    local filetype=$4

    local var
    local value
    
    if [ "$filetype" = "xml" ];
    then
        echo "Configuring $module : Filetype $filetype"
        for c in `printenv | perl -sne 'print "$1 " if m/^${envPrefix}_(.+?)=.*/' -- -envPrefix=$envPrefix`; do 
            name=`echo ${c} | perl -pe 's/___/-/g; s/__/@/g; s/_/./g; s/@/_/g;'`
            var="${envPrefix}_${c}"
            value=${!var}
            echo " - Setting $name=$value"
            addProperty $path $name "$value" $filetype
        done
    elif [ "$filetype" = "txt" ];
    then
        echo "Configuring $module : Filetype $filetype"
        for c in `printenv | perl -sne 'print "$1 " if m/^${envPrefix}_(.+?)=.*/' -- -envPrefix=$envPrefix`; do 
            name=`echo ${c} | perl -pe 's/___/-/g; s/__/@/g; s/_/./g; s/@/_/g;'`
            var="${envPrefix}_${c}"
            value=${!var}
            echo " - Setting $name=$value"
            addProperty $path $name "$value" $filetype
        done
    else
        echo "Unknown file type ${filetype} supplied.  Please try again."
    fi

}

roles=$(echo $NODE_ROLES | tr "," "\n")

for role in $roles; do
    if [ "$role" = "core" ];
    then
        echo "Configuring Hadoop Role"
        configure /etc/hadoop/core-site.xml core CORE_CONF xml
        configure /etc/hadoop/hdfs-site.xml hdfs HDFS_CONF xml
        configure /etc/hadoop/yarn-site.xml yarn YARN_CONF xml
        configure /etc/hadoop/httpfs-site.xml httpfs HTTPFS_CONF xml
        configure /etc/hadoop/kms-site.xml kms KMS_CONF xml
        configure /etc/hadoop/mapred-site.xml mapred MAPRED_CONF xml      
    elif [ "$role" = "hive" ];
    then 
        echo "Configuring Hive Role"
        configure /opt/hive/conf/hive-site.xml hive HIVE_SITE_CONF xml
    elif [ "$role" = "spark" ];
    then
        echo "Configuring Spark Role"
        configure /usr/local/spark/conf/spark-env.sh spark SPARK_CONF txt
    elif [ "$role" = "kafka" ];
    then
        echo "Configuring Kafka Role"
        configure /usr/share/kafka/config/server.properties kafka KAFKA_CONF txt
    else
        echo "Nothing more to configure"
    fi
done

function wait_for_it()
{
    local serviceport=$1
    local service=${serviceport%%:*}
    local port=${serviceport#*:}
    local retry_seconds=5
    local max_try=100
    let i=1

    nc -z $service $port
    result=$?

    until [ $result -eq 0 ]; do
      echo "[$i/$max_try] check for ${service}:${port}..."
      echo "[$i/$max_try] ${service}:${port} is not available yet"
      if (( $i == $max_try )); then
        echo "[$i/$max_try] ${service}:${port} is still not available; giving up after ${max_try} tries. :/"
        exit 1
      fi
      
      echo "[$i/$max_try] try in ${retry_seconds}s once again ..."
      let "i++"
      sleep $retry_seconds

      nc -z $service $port
      result=$?
    done
    echo "[$i/$max_try] $service:${port} is available."
}

for i in ${SERVICE_PRECONDITION[@]}
do
    wait_for_it ${i}
done

exec $@