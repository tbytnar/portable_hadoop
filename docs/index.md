# Portable Hadoop
## Mission Statement
The mission of the Portable Hadoop Environment (PHE) is to provide data professionals with a way to rapidly provision a barebones hadoop environment that allows the importing, manipulating and dissecting of data all from any machine with Docker installed.

## Description
The PHE has been designed to be a minimalistic environment to focus on the core aspects of the Hadoop ecosystem while still resembling a realistic architecture.  While there are intentions of adding more components through a modular container design, the essentials will always be the center of focus.  HDFS, YARN, Hive, Spark represent the core components of the PHE.  

While the current iteration uses Hadoop and Hive 2, future development of the PHE will include Hadoop and Hive 3 as its own independent environment.

## Uses for the PHE
* Training
* Development
* Proof of concept
* Continuous Development or Continuous Integration

## How to get started
Each of the environments is easily spun up on its own using docker-compose.  Follow the examples below to launch your environment of choice.
To launch Hadoop only:

    docker-compose up -d hadoop

To launch Hive (will also launch Hadoop):

    docker-compose up -d hive

To launch the client only:

    docker-compose up -d client

To launch Spark only:

    docker-compose up -d spark

To launch everything:
    
    docker-compose up -d

<br>

## Testing and What next?
> Begin following the training exercises here:  [Getting Started](../index.md)
<br>

## Requirements
Docker v20+
Windows
```
  - WSL 2
```

## Container Architecture
The Hadoop environment consists of the following containers:
* **Namenode** - The primary (master) Hadoop container
* **Datanode** - The secondary (worker) Hadoop container
* **Historyserver** - Job history server
* **Nodemanager** - Job execution nodes manager
* **Resourcemanager** - YARN resource manager
* **Client** - Jupyter Notebook and Python

The Hive environment consists of the following containers:
* **Hive-server** - HiveServer2 and all Hive executables
* **Hive-metastore** - Hive Metastore and PostgreSQL Metastore Database
  
The Spark environment consists of the following containers:
* **Spark Master** - Spark master (Client is configured to attach here)
* **Spark Worker 1** - Spark Worker 1 
* **Spark Worker 2** - Spark Worker 2
  
<br>

## Troubleshooting
### Windows
---
Occasional permission errors when attempting to run any Docker commands.
    
    Be sure to run Powershell as Administrator each time you interact with Docker.

Docker is taking up all the memory on my workstation

    See this link for information on how to limit Docker’s memory consumption:
    https://medium.com/@lewwybogus/how-to-stop-wsl2-from-hogging-all-your-ram-with-docker-d7846b9c5b37

ERROR: for (Container)  Cannot start service (Container): Ports are not available: listen tcp 0.0.0.0:(Port): bind: An attempt was made to access a socket in a way forbidden by its access permissions.

    This can happen occasionally as Windows Updates tend to change the Dynamic port ranges reserved on the IPv4 adapters.  This can be seen by executing the following:
    
      netsh interface ipv4 show excludedportrange protocol=tcp
    
    To fix the issue execute the following:

      netsh int ipv4 set dynamic tcp start=49152 num=16384
      net stop winnat
      net start winnat

<br>


## Future Plans (Road Map)
* Expand the client containers capabilities
  * Q1 2021
* Add more Hadoop ecosystem components as modular containers (Kafka, Ranger, etc...)
  * Q1 2021
* Improve Cross Platform Compatibility and Reliability
  * Q1 2021
* Hadoop v3/Hive v3
  * Q2 2021
* Baseline Performance “Edition”
  * Q3 2021
* Baseline Security “Edition”
  * Q4 2021



## Contributors
* Tim Bytnar [@tbytnar](https://github.com/tbytnar) (maintainer)

## Huge thanks to
* Ivan Ermilov [@earthquakesan](https://github.com/earthquakesan)
* Yiannis Mouchakis [@gmouchakis](https://github.com/gmouchakis)
* Ke Zhu [@shawnzhu](https://github.com/shawnzhu)
