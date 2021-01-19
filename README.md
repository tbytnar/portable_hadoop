# portable_hadoop
Mission Statement
The mission of the Portable Hadoop Environment (PHE) is to provide data professionals with a way to rapidly provision a barebones hadoop environment that allows the importing, manipulating and dissecting of data all from any machine with Docker installed.

Description
The PHE has been designed to be a minimalistic environment to focus on the core aspects of the Hadoop ecosystem while still resembling a realistic architecture.  While there are intentions of adding more components through a modular container design, the essentials will always be the center of focus.  HDFS, YARN, Hive, Spark represent the core components of the PHE.  

While the current iteration uses Hadoop and Hive 2, future development of the PHE will include Hadoop and Hive 3 as its own independent environment.
* Uses for the PHE
* Training
* Development
* Proof of concept
* Continuous Development or Continuous Integration

## How to get started
To run Hadoop/Hive:
```
    docker-compose up -d hive-server
```

To run Spark:
```
    docker-compose up -d spark-master
```

## Testing
Load data into Hive and test it:
```
  $ docker-compose exec hive-server bash
  # /opt/hive/bin/beeline -u jdbc:hive2://localhost:10000
  > CREATE TABLE pokes (foo INT, bar STRING);
  > LOAD DATA LOCAL INPATH '/opt/hive/examples/files/kv1.txt' OVERWRITE INTO TABLE pokes;
  > SELECT * FROM pokes;
```

## What next?
Open the Documentation directory and get started with the included exercises

## Requirements
Docker v20+
Windows
```
  - WSL 2
```

## Contributors
* Tim Bytnar [@tbytnar](https://github.com/tbytnar) (maintainer)

## Huge thanks to
* Ivan Ermilov [@earthquakesan](https://github.com/earthquakesan)
* Yiannis Mouchakis [@gmouchakis](https://github.com/gmouchakis)
* Ke Zhu [@shawnzhu](https://github.com/shawnzhu)
