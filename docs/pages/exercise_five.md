## Exercise Five

Scenario:  You’ve been given a flat file dataset and have been asked to create a partitioned table in hive for the data.  


### Step 1 - Uploading Flat File Data

If you still have the terminal shell open from the previous exercise, feel free to reuse that.  If not please launch a new terminal window.

You’ll need to know the full path to the source file you wish to inject into the Docker container.  Once you have this, then execute the following command:


```shell
docker cp "documentation/exercise_5/wnv_human_cases.csv" hive-server:/tmp
```

Once the command completes, your file has been injected into the /tmp/ directory on the datanode container


Validate that the file has been injected by attaching to the container’s shell and viewing the contents of the /tmp/ directory


```
docker-compose exec hive bash
ls /tmp/
```


> **Example**
> ```shell
> PS C:\Users\tab1018\Documents\Docker\portable_hadoop> docker cp "documentation/exercise_5/wnv_human_cases.csv" hive-server:/tmp
> PS C:\Users\tab1018\Documents\Docker\portable_hadoop> docker-compose exec hive bash
> root@b29450b15328:/opt# ls /tmp/
> 7f519d5b-5647-4126-8908-5110b77e29c6_resources  drivers.csv  hadoop-unjar9136625060577656635  hsperfdata_root  jetty-0.0.0.0-10002-hiveserver2-_-any-  parse_log.py  root  transactions.log  trucks.txt  wnv_human_cases.csv
> root@b29450b15328:/opt#
> ```

<br>

### Step 2 - Adding Flat File to HDFS

If you are still attached to the datanode container’s shell, feel free to reuse that.  If not please attach to that using the following:


```shell
docker-compose exec hive-server bash
```

Copy the source file from the /tmp/ directory to the flatfiles HDFS directory:


```shell
hdfs dfs -put /tmp/wnv_human_cases.csv /user/hive/flatfiles/
```

<br>

### Step 3 - Create SERDE table for flat file data

We will now connect to HiveServer2 via Beeline to perform the rest of the work.  Execute the following to do so:


```
beeline -u jdbc:hive2://localhost:10000
```

> **Example**
> ```shell
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
> ```

<br>

Now at the beeline prompt, copy and paste the following code to create a new SERDE table.

NOTE: We’re using the quoteChar setting here to remove the surrounding quotes for each of the cell values.


```sql
CREATE EXTERNAL TABLE wnv_cases (
    year STRING, 
    week STRING, 
    county STRING, 
    cases INT
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
    "separatorChar" = ",",
    "quoteChar"     = "\""
);
```


Next we’ll load the flatfile data into this table using the following:


```sql
LOAD DATA INPATH '/user/hive/flatfiles/wnv_human_cases.csv' INTO TABLE wnv_cases;
```

> **Example**
> ```shell
> 0: jdbc:hive2://localhost:10000> CREATE EXTERNAL TABLE wnv_cases (
> . . . . . . . . . . . . . . . .>     year STRING,
> . . . . . . . . . . . . . . . .>     week STRING,
> . . . . . . . . . . . . . . . .>     county STRING,
> . . . . . . . . . . . . . . . .>     cases INT
> . . . . . . . . . . . . . . . .> )
> . . . . . . . . . . . . . . . .> ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
> . . . . . . . . . . . . . . . .> WITH SERDEPROPERTIES (
> . . . . . . . . . . . . . . . .>     "separatorChar" = ",",
> . . . . . . . . . . . . . . . .>     "quoteChar"     = "\""
> . . . . . . . . . . . . . . . .> );
> No rows affected (0.121 seconds)
> 0: jdbc:hive2://localhost:10000> LOAD DATA INPATH '/user/hive/flatfiles/wnv_human_cases.csv' INTO TABLE wnv_cases;
> No rows affected (0.278 seconds)
> 0: jdbc:hive2://localhost:10000>
> ```

<br>

### Step 4 - Create Partitioned Table and Load data

Now that we’ve loaded the data into a SERDE table, we can create a new partitioned table using the following:

```sql
create table wnv_cases_part(year string,week string,cases INT) PARTITIONED BY(county string);
```

And finally we can load the data from the previously created SERDE table into the new partitioned table using this:

```sql
set hive.exec.dynamic.partition.mode=nonstrict;
INSERT OVERWRITE TABLE wnv_cases_part PARTITION(county)
SELECT year,week,cases,county from wnv_cases;
```

> **Example**
> ```shell
> 0: jdbc:hive2://localhost:10000> set hive.exec.dynamic.partition.mode=nonstrict;
> No rows affected (0.006 seconds)
> 0: jdbc:hive2://localhost:10000>
> 0: jdbc:hive2://localhost:10000> INSERT OVERWRITE TABLE wnv_cases_part PARTITION(county)
> . . . . . . . . . . . . . . . .>
> . . . . . . . . . . . . . . . .> SELECT year,week,cases,county from wnv_cases;
> WARNING: Hive-on-MR is deprecated in Hive 2 and may not be available in the future versions. Consider using a different execution engine (i.e. spark, tez) or using Hive 1.X releases.
> No rows affected (16.332 seconds)
> 0: jdbc:hive2://localhost:10000>
> ```

### Step 5 - Inspect HDFS

Feel free to run any SQL commands you want against that table (do not drop the table).  Once you have finished exit beeline by executing:  !q

Now at the shell prompt, execute this command:

```shell
hdfs dfs -ls /user/hive/warehouse/wnv_cases_part
```

It’s clear to see here how Hive partitioning works within HDFS.  Each record is now organized in it’s own county’s directory as seen below:

> **Example**
> ```shell
> root@b29450b15328:/opt# hdfs dfs -ls /user/hive/warehouse/wnv_cases_part
> Found 50 items
> drwxrwxr-x   - root supergroup          0 2021-02-09 02:56 /user/hive/warehouse/wnv_cases_part/county=Alameda
> drwxrwxr-x   - root supergroup          0 2021-02-09 02:56 /user/hive/warehouse/wnv_cases_part/county=Amador
> drwxrwxr-x   - root supergroup          0 2021-02-09 02:56 /user/hive/warehouse/wnv_cases_part/county=Butte
> drwxrwxr-x   - root supergroup          0 2021-02-09 02:56 /user/hive/warehouse/wnv_cases_part/county=Calaveras
> drwxrwxr-x   - root supergroup          0 2021-02-09 02:56 /user/hive/warehouse/wnv_cases_part/county=Colusa
> drwxrwxr-x   - root supergroup          0 2021-02-09 02:56 /user/hive/warehouse/wnv_cases_part/county=Contra Costa
> drwxrwxr-x   - root supergroup          0 2021-02-09 02:56 /user/hive/warehouse/wnv_cases_part/county=County
> ...
> root@b29450b15328:/opt#
> ```

