
## Exercise Three

Scenario: In this exercise you will be parsing the transactions.log file from Challenge 1 using a Python UDF.  After this exercise you should be proficient with the following:



*   Uploading and adding a python script to the Hive Server
*   Adding that Python script to Hive’s Resource Pool
*   Writing a Hive SQL View that uses the Python script to parse an unformatted log record


### Step 1 - Uploading Python Script to Hive Server

If you still have the terminal shell open from the previous section, feel free to reuse that.  If not please launch a new terminal window.

You’ll need to know the full path to the python file you need to inject into the Docker container.  Once you have this, then execute the following command:

```shell
docker cp "documentation/exercise_3/parse_log.py" hive-server:/tmp
```

We’ll also be reusing the log file from Challenge 1 so execute the following to upload it to the Hive Server.

```shell
docker cp "documentation/challenge_1/transactions.log" hive-server:/tmp
```

> **Example**
> ```shell
> PS D:\Development\portable_hadoop> docker cp "documentation/exercise_3/parse_log.py" hive-server:/tmp
> PS D:\Development\portable_hadoop> docker cp "documentation/challenge_1/transactions.log" hive-server:/tmp
> PS D:\Development\portable_hadoop>
> ```

Validate that the file has been injected by attaching to the container’s shell and viewing the contents of the /tmp/ directory

```shell
docker-compose exec hive bash
ls /tmp/
```

> **Example**
> ```shell
> PS D:\Development\portable_hadoop> docker-compose exec hive bash
> root@4c9caa1f551d:/opt# ls /tmp/
> 3b2f6978-ac26-4435-9bc4-bb9ce289728c_resources  435106ff-8421-4c28-bbcf-63b512eed00c_resources  hadoop-unjar2534986790954184614  hsperfdata_root  jetty-0.0.0.0-10002-hiveserver2-_-any-  parse_log.py  root  transactions.log
> root@4c9caa1f551d:/opt#
> ```

<br>

### Step 2 - Adding Files to HDFS

If you are still attached to the datanode container’s shell, feel free to reuse that.  If not please attach to that using the following:

```shell
docker-compose exec hive-server bash
```

Hive already has a warehouse directory configured in HDFS, it is located here:

> /user/hive/warehouse

For the purposes of this exercise we are going to assume that the standard operating procedure for this environment is to contain all database and table sources within the warehouse directory.  However we will need to create sub-directory structures for each database and table.  This can be done with a single command (note the use of the -p switch).


```shell
hdfs dfs -mkdir -p /user/hive/warehouse/pythonudf/transactions
```

Copy the python and log files from the /tmp/ directory to their destinations in HDFS:

```shell
hdfs dfs -put /tmp/parse_log.py /user/hive/
hdfs dfs -put /tmp/transactions.log /user/hive/warehouse/pythonudf/transactions/
```

> **Example**
> ```shell
> root@4c9caa1f551d:/opt# hdfs dfs -mkdir -p /user/hive/warehouse/pythonudf/transactions
> root@4c9caa1f551d:/opt# hdfs dfs -put /tmp/parse_log.py /user/hive/
> root@4c9caa1f551d:/opt# hdfs dfs -put /tmp/transactions.log /user/hive/warehouse/pythonudf/transactions/
> root@4c9caa1f551d:/opt#
> ```

<br>

### Step 3 - Connect to Hive via Beeline

We will now connect to HiveServer2 via Beeline to perform the rest of the work.  Execute the following to do so:

```
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

<br>

### Step 4 - Add file to Hive resources

Now at the beeline prompt, you will need to add the python script to the Hive resource pool.  This is done by executing the following:

ADD FILE hdfs://namenode/user/hive/parse_log.py;

This makes the python script available to be used by the cluster during the Mapreduce operations.

> **Example**
> ```shell
> 0: jdbc:hive2://localhost:10000> ADD FILE hdfs://namenode/user/hive/parse_log.py;
> No rows affected (0.175 seconds)
> 0: jdbc:hive2://localhost:10000>
> ```

<br>

### Step 5 - Create Database and Table

Still at the beeline prompt, execute the following commands to create a new database and table for the transactions log data:

```sql
CREATE DATABASE IF NOT EXISTS pythonudf;
CREATE EXTERNAL TABLE IF NOT EXISTS pythonudf.transactions
(
    logline STRING
)
ROW FORMAT DELIMITED
STORED AS TEXTFILE
LOCATION 'hdfs://namenode:8020/user/hive/warehouse/pythonudf/transactions';
```

### 

> **Example**
> ```shell
> 0: jdbc:hive2://localhost:10000> CREATE DATABASE IF NOT EXISTS pythonudf;
> No rows affected (0.741 seconds)
> 0: jdbc:hive2://localhost:10000> CREATE EXTERNAL TABLE IF NOT EXISTS pythonudf.transactions
> . . . . . . . . . . . . . . . .> (
> . . . . . . . . . . . . . . . .>     logline STRING
> . . . . . . . . . . . . . . . .> )
> . . . . . . . . . . . . . . . .> ROW FORMAT DELIMITED
> . . . . . . . . . . . . . . . .> STORED AS TEXTFILE
> . . . . . . . . . . . . . . . .> LOCATION 'hdfs://namenode:8020/user/hive/warehouse/pythonudf/transactions';
> No rows affected (0.226 seconds)
> 0: jdbc:hive2://localhost:10000>
> ```

<br>

### Step 6 - Create View from TRANSFORM Query

Now execute the following to create a view from a TRANSFORM query that utilizes the Python script to parse the log data:

```sql
CREATE VIEW pythonudf.transactions_parsed AS
SELECT
    TRANSFORM (logline) USING 'python parse_log.py' AS 
        ip_address   
        ,hyphen
        ,user_name
        ,datetime
        ,rest_method
        ,url_path
        ,engine
        ,return_code
        ,bank_id
        ,referrer
        ,browser
        ,operating_system
        ,browser_detail
FROM pythonudf.transactions;
```


> **Example**
> ```shell
> 0: jdbc:hive2://localhost:10000> CREATE VIEW pythonudf.transactions_parsed AS
> . . . . . . . . . . . . . . . .> SELECT
> . . . . . . . . . . . . . . . .>     TRANSFORM (logline) USING 'python parse_log.py' AS
> . . . . . . . . . . . . . . . .>         ip_address
> . . . . . . . . . . . . . . . .>         ,hyphen
> . . . . . . . . . . . . . . . .>         ,user_name
> . . . . . . . . . . . . . . . .>         ,datetime
> . . . . . . . . . . . . . . . .>         ,rest_method
> . . . . . . . . . . . . . . . .>         ,url_path
> . . . . . . . . . . . . . . . .>         ,engine
> . . . . . . . . . . . . . . . .>         ,return_code
> . . . . . . . . . . . . . . . .>         ,bank_id
> . . . . . . . . . . . . . . . .>         ,referrer
> . . . . . . . . . . . . . . . .>         ,browser
> . . . . . . . . . . . . . . . .>         ,operating_system
> . . . . . . . . . . . . . . . .>         ,browser_detail
> . . . . . . . . . . . . . . . .> FROM pythonudf.transactions;
> No rows affected (0.169 seconds)
> 0: jdbc:hive2://localhost:10000>
> ```

<br>

### Step 7 - Select from New View

Finally here is an example SELECT statement you can execute to view some columns of the first five records:

```sql
SELECT ip_address, user_name, bank_id FROM pythonudf.transactions_parsed LIMIT 5;
```

> **Example**
> ```shell
> 0: jdbc:hive2://localhost:10000> SELECT ip_address, user_name, bank_id FROM pythonudf.transactions_parsed LIMIT 5;
> WARNING: Hive-on-MR is deprecated in Hive 2 and may not be available in the future versions. Consider using a different execution engine (i.e. spark, tez) or using Hive 1.X releases.
> +-----------------+---------------+----------+
> |   ip_address    |   user_name   | bank_id  |
> +-----------------+---------------+----------+
> | 13.200.56.57    | funk2780      | 22       |
> | 36.196.137.210  | hansen6533    | 9        |
> | 175.17.18.238   | johnston5222  | 25       |
> | 86.219.181.14   | jacobi7002    | 12       |
> | 88.225.160.81   | ondricka8103  | 25       |
> +-----------------+---------------+----------+
> 5 rows selected (13.321 seconds)
> 0: jdbc:hive2://localhost:10000>


 > [Go back to Challenge 1](exercise_two.md)

 > [Continue on to Exercise 4](exercise_four.md)