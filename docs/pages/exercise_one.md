## Exercise One

After completing this exercise you will be proficient in the following tasks:

*   Uploading flat-file data to an edge node
*   Inserting that data into HDFS
*   Creating a Hive database
*   Creating a Hive table for the data
*   Querying the data

For this exercise a data file has been provided with the source files here: documentation\exercise_1\test-data.csv

<br>

### Step 1 - Uploading Flat File Data
If you still have the terminal shell open from the “Before Getting Started” section, feel free to reuse that.  If not please launch a new terminal window.

You’ll need to know the full path to the source file you wish to inject into the Docker container.  Once you have this, then execute the following command:


```shell
docker cp "documentation/exercise_1/test-data.csv" datanode:/tmp
```

Once the command completes, your file has been injected into the /tmp/ directory on the datanode container.
    
> **Example**<br>
> ```shell
> PS D:\Development\portable_hadoop> docker cp '.\documentation\exercise_1\test-data.csv' datanode:/tmp
> PS D:\Development\portable_hadoop>
> ```

Validate that the file has been injected by attaching to the container’s shell and viewing the contents of the /tmp/ directory

```shell
docker-compose exec datanode bash
ls /tmp/
```

> **Example**<br>
> ```shell
> PS D:\Development\portable_hadoop> docker-compose exec datanode bash
> 
> root@04b899b5bb98:/# ls /tmp<br>
> Jetty_localhost_38001_datanode____.alxwtp  hsperfdata_root  test-data.csv<br>
> root@04b899b5bb98:/#
> ```

<br>

### Step 2 - Adding Flat File to HDFS

If you are still attached to the datanode container’s shell, feel free to reuse that.  If not please attach to that using the following:


```shell
docker-compose exec datanode bash
```


Hive already has a warehouse directory configured in HDFS, it is located here:

> **/user/hive/warehouse**

For the purposes of this exercise we are going to assume that the standard operating procedure for this environment is to contain all database and table sources within the warehouse directory.  However we will need to create sub-directory structures for each database and table.  This can be done with a single command (note the use of the -p switch).


```shell
hdfs dfs -mkdir -p /user/hive/warehouse/phe-demo/test-data
```

Copy the source file from the /tmp/ directory to the newly created HDFS directory:

```shell
hdfs dfs -put /tmp/test-data.csv /user/hive/warehouse/phe-demo/test-data/
```

> **Example**<br>
> ```shell
> root@04b899b5bb98:/# hdfs dfs -mkdir -p /user/hive/warehouse/phe-demo/test-data
> root@04b899b5bb98:/# hdfs dfs -put /tmp/test-data.csv /user/hive/warehouse/phe-demo/test-data/
> root@04b899b5bb98:/#
> ```

At this point we have completed our work in the datanode container.  You can now leave its shell prompt by executing the following:

```shell
exit
```

<br>

### Step 3 - Create Hive Database

You will now need to attach to the hive-server’s shell.  Do this by executing the following in terminal:

```shell
docker-compose exec hive bash
```

Once at the prompt you will now launch Beeline while attaching to the Hive server by executing the following command:

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

Now at the beeline prompt connected to Hive you can create a new database by executing the following SQL statement:

```sql
CREATE DATABASE PHEDEMO;
```

> **Example**
> ```shell
> 0: jdbc:hive2://localhost:10000> CREATE DATABASE PHEDEMO;
> No rows affected (1.094 seconds)
> 0: jdbc:hive2://localhost:10000>
> ```

Confirm the database was created successfully by executing:

```sql
SHOW DATABASES;
```
> **Example**<br>
> ```shell
> 0: jdbc:hive2://localhost:10000> SHOW DATABASES;
> +----------------+
> | database_name  |
> +----------------+
> | default        |
> | phedemo        |
> +----------------+
> 2 rows selected (0.203 seconds)
> 0: jdbc:hive2://localhost:10000>
> ```



Without exiting terminal or the beeline prompt proceed to the next step 


### Step 4 - Create Hive Table for Data

Copy or type the folowing sql statement and then paste it into the terminal so it is executed at the beeline terminal. NOTE: You will see “No rows affected…” when the statement completes.

```sql
CREATE EXTERNAL TABLE IF NOT EXISTS phedemo.testdata
(
    ID int,
    notes string,
    date_entered date,
    reg_no bigint
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION 'hdfs://namenode:8020/user/hive/warehouse/phe-demo/test-data';
```



> **Example**
> ```shell
> 0: jdbc:hive2://localhost:10000> CREATE EXTERNAL TABLE IF NOT EXISTS phedemo.testdata
> . . . . . . . . . . . . . . . .> (
> . . . . . . . . . . . . . . . .>     ID int,
> . . . . . . . . . . . . . . . .>     notes string,
> . . . . . . . . . . . . . . . .>     date_entered date,
> . . . . . . . . . . . . . . . .>     reg_no bigint
> . . . . . . . . . . . . . . . .> )
> . . . . . . . . . . . . . . . .> ROW FORMAT DELIMITED
> . . . . . . . . . . . . . . . .> FIELDS TERMINATED BY ','
> . . . . . . . . . . . . . . . .> STORED AS TEXTFILE
> . . . . . . . . . . . . . . . .> LOCATION 'hdfs://namenode:8020/user/hive/warehouse/phe-demo/test-data';
> No rows affected (0.275 seconds)
> 0: jdbc:hive2://localhost:10000>
```

Verify that the table has been created and that data is now accessible by selecting everything from it:

```sql
SELECT * FROM phedemo.testdata;
```

> **Example**
> ```shell
> 0: jdbc:hive2://localhost:10000> SELECT * FROM phedemo.testdata;
> +--------------+------------------------------------+------------------------+------------------+
> | testdata.id  |           testdata.notes           | testdata.date_entered  | testdata.reg_no  |
> +--------------+------------------------------------+------------------------+------------------+
> | 123          |  This is just a test record        | NULL                   | NULL             |
> | 456          |  This is just another test record  | NULL                   | NULL             |
> | 789          |  This is also a test record        | NULL                   | NULL             |
> | 124          |  This is only a test record        | NULL                   | NULL             |
> | 125          |  This is just a test record        | NULL                   | NULL             |
> +--------------+------------------------------------+------------------------+------------------+
> 5 rows selected (1.488 seconds)
> 0: jdbc:hive2://localhost:10000>
> ```

You can now execute SQL statements against the table.  When you are finished, execute !q at the beeline prompt.  Then execute exit at the bash shell to leave the hive-server container. 


 > [Go back to Getting Started](../index.md)

 > [Continue on to Exercise 2](../pages/exercise_two.md)