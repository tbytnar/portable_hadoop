## Exercise Two

**Scenario**: You have been given two flat files.  One is comma delimited and contains records for truck drivers, the other is an export of truck logs.  You are tasked with importing the data into a Hive database and joining the data together.

After completing this exercise you will be proficient in the following tasks:

*   Creating a Hive database with multiple tables from flat file data
*   Using Regex to import log formatted data
*   Executing Hive SQL statements joining multiple tables data together

For this exercise a data file has been provided with the source files here: documentation\Exercise 2\


### Step 1 - Uploading Flat File Data

If you still have the terminal shell open from the “Before Getting Started” section, feel free to reuse that.  If not please launch a new terminal window.

You’ll need to know the full path to the source file you wish to inject into the Docker container.  Once you have this, then execute the following commands:


```shell
    docker cp "documentation/exercise_2/drivers.csv" hive-server:/tmp
    docker cp "documentation/exercise_2/trucks.txt" hive-server:/tmp
```

> **Example**
> ```shell
> PS C:\Users\tab1018\Documents\Docker\portable_hadoop> docker cp "documentation/exercise_2/drivers.csv" hive-server:/tmp
> PS C:\Users\tab1018\Documents\Docker\portable_hadoop> docker cp "documentation/exercise_2/trucks.txt" hive-server:/tmp
> PS C:\Users\tab1018\Documents\Docker\portable_hadoop>
> ```


**NOTE:** In the previous exercise you uploaded the data files to the datanode.  Here we are uploading directly to the hive-server for efficiency.

<br>

### Step 2 - Adding flat files to HDFS

Now that the flat files have been uploaded to the container, you will need to connect to its shell.  To do so execute the following in your terminal window:


```shell
    docker-compose exec hive-server bash
```


Now inside the container, you can validate the flat files are there by running this:


```shell
    ls /tmp/
```

> **Example**
> ```shell
> PS C:\Users\tab1018\Documents\Docker\portable_hadoop> docker-compose exec hive bash
> root@b29450b15328:/opt# ls /tmp
> 7f519d5b-5647-4126-8908-5110b77e29c6_resources  drivers.csv  hadoop-unjar9136625060577656635  hsperfdata_root  jetty-0.0.0.0-10002-hiveserver2-_-any-  root  trucks.txt
> ```


Next you’ll need to create a directory structure for the new database and its tables.  Execute the following commands:


```shell
hdfs dfs -mkdir -p /user/hive/flatfiles/
hdfs dfs -put /tmp/trucks.txt /user/hive/flatfiles/
hdfs dfs -put /tmp/drivers.csv /user/hive/flatfiles/
```

**NOTE:** In the previous exercise you uploaded the files into a directory on HDFS which specified the database and table names in its path.  This time we are uploading the files to a static folder and will be loading the data into the Hive tables with a different method.  It's important to remember that there are several ways to accomplish the same goal.

> **Example**
> ```shell
> root@b29450b15328:/opt# hdfs dfs -mkdir -p /user/hive/flatfiles/
> root@b29450b15328:/opt# hdfs dfs -put /tmp/trucks.txt /user/hive/flatfiles/
> root@b29450b15328:/opt# hdfs dfs -put /tmp/drivers.csv /user/hive/flatfiles/
> root@b29450b15328:/opt#
> ```


<br>

### Step 3 - Create the new database

Now with the data files in HDFS we can connect to HiveServer using beeline:


```shell
beeline -u jdbc:hive2://localhost:10000
```

> **Example**
> root@df9140664a0f:/opt# beeline -u jdbc:hive2://localhost:10000 <br>
> SLF4J: Class path contains multiple SLF4J bindings.<br>
> SLF4J: Found binding in [jar:file:/opt/hive/lib/log4j-slf4j-impl-2.6.2.jar!/org/slf4j/impl/StaticLoggerBinder.class]<br>
> SLF4J: Found binding in [jar:file:/opt/hadoop-2.10.1/share/hadoop/common/lib/slf4j-log4j12-1.7.25.jar!/org/slf4j/impl/StaticLoggerBinder.class]<br>
> SLF4J: See http://www.slf4j.org/codes.html#multiple_bindings for an explanation.<br>
> SLF4J: Actual binding is of type [org.apache.logging.slf4j.Log4jLoggerFactory]<br>
> Connecting to jdbc:hive2://localhost:10000<br>
> Connected to: Apache Hive (version 2.3.7)<br>
> Driver: Hive JDBC (version 2.3.7)<br>
> Transaction isolation: TRANSACTION_REPEATABLE_READ<br>
> Beeline version 2.3.7 by Apache Hive<br>
> 0: jdbc:hive2://localhost:10000><br>


Next you’ll need to create a database to house the new tables.  Execute the following to do so:

```sql
CREATE DATABASE truckingco;
```

> **Example**
> ```shell
> 
> ```

Copy or type the below statements and then paste it into the terminal so it is executed at the beeline prompt. 


**Drivers Table**
```sql
DROP TABLE IF EXISTS truckingco.drivers;

CREATE EXTERNAL TABLE truckingco.drivers
(
    id INT,
    firstname STRING,
    lastname STRING,
    startdate STRING,
    rate INT,
    location STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

LOAD DATA INPATH "/user/hive/flatfiles/drivers.csv" OVERWRITE INTO TABLE truckingco.drivers;
```

**Trucks Table**
```sql
DROP TABLE IF EXISTS truckingco.trucks;

CREATE TABLE truckingco.trucks (
  `datetime` STRING,
  shipping_id STRING,
  shipping_name STRING,
  owner_id STRING,
  owner_name STRING,
  `status` STRING,
  `location` STRING
  )
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.RegexSerDe'
WITH SERDEPROPERTIES (
  "input.regex" = "([^ ]* [^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) (.*)",
  "output.format.string" = "%1$s %2$s %3$s %4$s %5$s %6$s %7$s"
)
STORED AS TEXTFILE;

LOAD DATA INPATH "/user/hive/flatfiles/trucks.txt" OVERWRITE INTO TABLE truckingco.trucks;
```

**NOTE:** You will see "No rows affected…" when the statement completes.  Also pay close attention to the SERDEPROPERTIES in trucks.sql.  We are using a regex string here to parse the log file's format and convert the text into structured data. Also note that we have instead created empty tables and loaded data into them using the LOAD DATA command. 
    

> **Example**
> ```shell
> 0: jdbc:hive2://localhost:10000> CREATE DATABASE truckingco;
> No rows affected (0.096 seconds)
> 0: jdbc:hive2://localhost:10000> DROP TABLE IF EXISTS truckingco.drivers;
> No rows affected (0.055 seconds)
> 0: jdbc:hive2://localhost:10000>
> 0: jdbc:hive2://localhost:10000> CREATE EXTERNAL TABLE truckingco.drivers
> . . . . . . . . . . . . . . . .> (
> . . . . . . . . . . . . . . . .>     id INT,
> . . . . . . . . . . . . . . . .>     firstname STRING,
> . . . . . . . . . . . . . . . .>     lastname STRING,
> . . . . . . . . . . . . . . . .>     startdate STRING,
> . . . . . . . . . . . . . . . .>     rate INT,
> . . . . . . . . . . . . . . . .>     location STRING
> . . . . . . . . . . . . . . . .> )
> . . . . . . . . . . . . . . . .> ROW FORMAT DELIMITED
> . . . . . . . . . . . . . . . .> FIELDS TERMINATED BY ','
> . . . . . . . . . . . . . . . .> STORED AS TEXTFILE;
> No rows affected (0.28 seconds)
> 0: jdbc:hive2://localhost:10000>
> 0: jdbc:hive2://localhost:10000> LOAD DATA INPATH "/user/hive/flatfiles/drivers.csv" OVERWRITE INTO TABLE truckingco.drivers;
> No rows affected (0.476 seconds)
> 0: jdbc:hive2://localhost:10000>
> ```



    

> **Example**
> ```shell
> 0: jdbc:hive2://localhost:10000> DROP TABLE IF EXISTS truckingco.trucks;
> No rows affected (0.063 seconds)
> 0: jdbc:hive2://localhost:10000>
> 0: jdbc:hive2://localhost:10000> CREATE TABLE truckingco.trucks (
> . . . . . . . . . . . . . . . .>   `datetime` STRING,
> . . . . . . . . . . . . . . . .>   shipping_id STRING,
> . . . . . . . . . . . . . . . .>   shipping_name STRING,
> . . . . . . . . . . . . . . . .>   owner_id STRING,
> . . . . . . . . . . . . . . . .>   owner_name STRING,
> . . . . . . . . . . . . . . . .>   `status` STRING,
> . . . . . . . . . . . . . . . .>   `location` STRING
> . . . . . . . . . . . . . . . .>   )
> . . . . . . . . . . . . . . . .> ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.RegexSerDe'
> . . . . . . . . . . . . . . . .> WITH SERDEPROPERTIES (
> . . . . . . . . . . . . . . . .>   "input.regex" = "([^ ]* [^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) (.*)",
> . . . . . . . . . . . . . . . .>   "output.format.string" = "%1$s %2$s %3$s %4$s %5$s %6$s %7$s"
> . . . . . . . . . . . . . . . .> )
> . . . . . . . . . . . . . . . .> STORED AS TEXTFILE;
> No rows affected (0.094 seconds)
> 0: jdbc:hive2://localhost:10000>
> 0: jdbc:hive2://localhost:10000> LOAD DATA INPATH "/user/hive/flatfiles/trucks.txt" OVERWRITE INTO TABLE truckingco.trucks;
> No rows affected (0.329 seconds)
> 0: jdbc:hive2://localhost:10000>
> ```



### Step 4 - Joining the data together in a SQL query

Now that the tables have been created and data has been loaded, we can execute a SQL query against them to join the data:


```
    SELECT * FROM truckingco.drivers d JOIN truckingco.trucks t ON d.location = t.location WHERE d.id = 4;
```

> **Example**
> ```sql
> 0: jdbc:hive2://localhost:10000> SELECT * FROM truckingco.drivers d JOIN truckingco.trucks t ON d.location = t.location WHERE d.id = 4;
> WARNING: Hive-on-MR is deprecated in Hive 2 and may not be available in the future versions. Consider using a different execution engine (i.e. spark, tez) or using Hive 1.X releases.
> SLF4J: Class path contains multiple SLF4J bindings.
> SLF4J: Found binding in [jar:file:/opt/hive/lib/log4j-slf4j-impl-2.6.2.jar!/org/slf4j/impl/StaticLoggerBinder.class]
> SLF4J: Found binding in [jar:file:/opt/hadoop-2.10.1/share/hadoop/common/lib/slf4j-log4j12-1.7.25.jar!/org/slf4j/impl/StaticLoggerBinder.class]
> SLF4J: See http://www.slf4j.org/codes.html#multiple_bindings for an explanation.
> SLF4J: Actual binding is of type [org.apache.logging.slf4j.Log4jLoggerFactory]
> Execution log at: /tmp/root/root_20210203214459_17df1ba1-6f72-461f-91f4-3215f30b9269.log
> 2021-02-03 21:45:02     Starting to launch local task to process map join;      maximum memory = 477626368
> 2021-02-03 21:45:03     Dump the side-table for tag: 0 with group count: 1 into file: file:/tmp/root/e17b7b47-f80e-4ae2-8fb7-ffd059eae320/hive_2021-02-03_21-44-59_479_739774916133018087-2/-local-10004/HashTable-Stage-3/MapJoin-mapfile00--.hashtable
> 2021-02-03 21:45:03     Uploaded 1 File to: file:/tmp/root/e17b7b47-f80e-4ae2-8fb7-ffd059eae320/hive_2021-02-03_21-44-59_479_739774916133018087-2/-local-10004/HashTable-Stage-3/MapJoin-mapfile00--.hashtable (314 bytes)
> 2021-02-03 21:45:03     End of local task; Time Taken: 0.979 sec.
> +-------+--------------+-------------+--------------+---------+-------------+--------------------------+----------------+-------------------+-------------+----------------+-----------+-------------+
> | d.id  | d.firstname  | d.lastname  | d.startdate  | d.rate  | d.location  |        t.datetime        | t.shipping_id  |  t.shipping_name  | t.owner_id  |  t.owner_name  | t.status  | t.location  |
> +-------+--------------+-------------+--------------+---------+-------------+--------------------------+----------------+-------------------+-------------+----------------+-----------+-------------+
> | 4     | camron       | stevens     | 7-18-2012    | 22      | Allentown   | 2021-01-12 17:54:13,846  | 25580          | log-generator.py  | 145         | log-generator  | DEBUG     | Allentown   |
> | 4     | camron       | stevens     | 7-18-2012    | 22      | Allentown   | 2021-01-12 17:55:27,91   | 25580          | log-generator.py  | 145         | log-generator  | DEBUG     | Allentown   |
> | 4     | camron       | stevens     | 7-18-2012    | 22      | Allentown   | 2021-01-12 18:03:19,987  | 25580          | log-generator.py  | 145         | log-generator  | DEBUG     | Allentown   |
> | 4     | camron       | stevens     | 7-18-2012    | 22      | Allentown   | 2021-01-12 18:04:20,617  | 25580          | log-generator.py  | 145         | log-generator  | DEBUG     | Allentown   |
> | 4     | camron       | stevens     | 7-18-2012    | 22      | Allentown   | 2021-01-12 18:05:45,887  | 25580          | log-generator.py  | 145         | log-generator  | DEBUG     | Allentown   |
> | 4     | camron       | stevens     | 7-18-2012    | 22      | Allentown   | 2021-01-12 18:17:08,466  | 25580          | log-generator.py  | 145         | log-generator  | DEBUG     | Allentown   |
> | 4     | camron       | stevens     | 7-18-2012    | 22      | Allentown   | 2021-01-12 18:18:07,786  | 25580          | log-generator.py  | 145         | log-generator  | DEBUG     | Allentown   |
> | 4     | camron       | stevens     | 7-18-2012    | 22      | Allentown   | 2021-01-12 18:23:25,403  | 25580          | log-generator.py  | 145         | log-generator  | DEBUG     | Allentown   |
> | 4     | camron       | stevens     | 7-18-2012    | 22      | Allentown   | 2021-01-12 18:26:19,730  | 25580          | log-generator.py  | 145         | log-generator  | DEBUG     | Allentown   |
> | 4     | camron       | stevens     | 7-18-2012    | 22      | Allentown   | 2021-01-12 18:28:52,586  | 25580          | log-generator.py  | 145         | log-generator  | DEBUG     | Allentown   |
> | 4     | camron       | stevens     | 7-18-2012    | 22      | Allentown   | 2021-01-12 18:28:57,24   | 25580          | log-generator.py  | 145         | log-generator  | DEBUG     | Allentown   |
> | 4     | camron       | stevens     | 7-18-2012    | 22      | Allentown   | 2021-01-12 18:29:06,49   | 25580          | log-generator.py  | 145         | log-generator  | DEBUG     | Allentown   |
> | 4     | camron       | stevens     | 7-18-2012    | 22      | Allentown   | 2021-01-12 18:29:06,794  | 25580          | log-generator.py  | 145         | log-generator  | DEBUG     | Allentown   |
> | 4     | camron       | stevens     | 7-18-2012    | 22      | Allentown   | 2021-01-12 18:31:40,575  | 25580          | log-generator.py  | 145         | log-generator  | DEBUG     | Allentown   |
> | 4     | camron       | stevens     | 7-18-2012    | 22      | Allentown   | 2021-01-12 18:33:19,808  | 25580          | log-generator.py  | 145         | log-generator  | DEBUG     | Allentown   |
> | 4     | camron       | stevens     | 7-18-2012    | 22      | Allentown   | 2021-01-12 18:34:55,707  | 25580          | log-generator.py  | 145         | log-generator  | DEBUG     | Allentown   |
> | 4     | camron       | stevens     | 7-18-2012    | 22      | Allentown   | 2021-01-12 18:35:24,450  | 25580          | log-generator.py  | 145         | log-generator  | DEBUG     | Allentown   |
> | 4     | camron       | stevens     | 7-18-2012    | 22      | Allentown   | 2021-01-12 18:35:30,676  | 25580          | log-generator.py  | 145         | log-generator  | DEBUG     | Allentown   |
> | 4     | camron       | stevens     | 7-18-2012    | 22      | Allentown   | 2021-01-12 18:36:34,289  | 25580          | log-generator.py  | 145         | log-generator  | DEBUG     | Allentown   |
> | 4     | camron       | stevens     | 7-18-2012    | 22      | Allentown   | 2021-01-12 18:39:00,397  | 25580          | log-generator.py  | 145         | log-generator  | DEBUG     | Allentown   |
> | 4     | camron       | stevens     | 7-18-2012    | 22      | Allentown   | 2021-01-12 18:40:26,540  | 25580          | log-generator.py  | 145         | log-generator  | DEBUG     | Allentown   |
> +-------+--------------+-------------+--------------+---------+-------------+--------------------------+----------------+-------------------+-------------+----------------+-----------+-------------+
> 21 rows selected (19.036 seconds)
> 0: jdbc:hive2://localhost:10000>
> ```


Now you are able to report on all the truck logs for Camron Stevens.  Feel free to play around further with more complex SQL queries.  Once you are finished, exit beeline by typing: 
```
!q
```

Last take a look at the directory structure inside of HDFS by executing the following commands:


```
    hdfs dfs -ls /user/hive/warehouse/
        NOTE: truckingco.db was automatically created after executing the CREATE DATABASE command
    hdfs dfs -ls /user/hive/warehouse/truckingco.db/
    NOTE: drivers and trucks were automatically created after executing the CREATE EXTERNAL TABLE commands
```

> **Example**
> ```shell
> root@b29450b15328:/opt# hdfs dfs -ls /user/hive/warehouse/
> Found 3 items
> drwxr-xr-x   - root supergroup          0 2021-02-03 20:17 /user/hive/warehouse/phe-demo
> drwxrwxr-x   - root supergroup          0 2021-02-03 20:22 /user/hive/warehouse/phedemo.db
> drwxrwxr-x   - root supergroup          0 2021-02-03 21:43 /user/hive/warehouse/truckingco.db
> root@b29450b15328:/opt#
> ```


> **Example**
> ```shell
> root@b29450b15328:/opt# hdfs dfs -ls /user/hive/warehouse/truckingco.db/
> Found 2 items
> drwxrwxr-x   - root supergroup          0 2021-02-03 21:42 /user/hive/warehouse/truckingco.db/drivers
> drwxrwxr-x   - root supergroup          0 2021-02-03 21:43 /user/hive/warehouse/truckingco.db/trucks
> root@b29450b15328:/opt#
> ```


 > [Go back to Exercise 1](exercise_one.md)

 > [Continue on to Challenge 1](challenge_one.md)