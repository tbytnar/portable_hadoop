
## Exercise Three

Scenario: In this exercise you will be parsing the transactions.log file from Challenge 1 using a Python UDF.  After this exercise you should be proficient with the following:



*   Uploading and adding a python script to the Hive Server
*   Adding that Python script to Hive’s Resource Pool
*   Writing a Hive SQL View that uses the Python script to parse an unformatted log record


### Step 1 - Uploading Python Script to Hive Server

If you still have the terminal shell open from the previous section, feel free to reuse that.  If not please launch a new terminal window.

You’ll need to know the full path to the python file you need to inject into the Docker container.  Once you have this, then execute the following command:


```
    docker cp "documentation/Exercise 3/parse_log.py" hive-server:/tmp
```



    We’ll also be reusing the log file from Challenge 1 so execute the following to upload it to the Hive Server.


```
    docker cp "documentation/Challenge 1/transactions.log" hive-server:/tmp
```



    

<p id="gdcalert16" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/image16.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert17">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/image16.png "image_tooltip")


Validate that the file has been injected by attaching to the container’s shell and viewing the contents of the /tmp/ directory


```
    docker-compose exec hive-server bash
    ls /tmp/
```



    

<p id="gdcalert17" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/image17.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert18">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/image17.png "image_tooltip")



### Step 2 - Adding Files to HDFS

If you are still attached to the datanode container’s shell, feel free to reuse that.  If not please attach to that using the following:


```
    docker-compose exec hive-server bash
```


Hive already has a warehouse directory configured in HDFS, it is located here:


    /user/hive/warehouse

For the purposes of this exercise we are going to assume that the standard operating procedure for this environment is to contain all database and table sources within the warehouse directory.  However we will need to create sub-directory structures for each database and table.  This can be done with a single command (note the use of the -p switch).


```
    hdfs dfs -mkdir -p /user/hive/warehouse/python-udf/transactions
```



    

<p id="gdcalert18" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/image18.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert19">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/image18.png "image_tooltip")


Copy the python and log files from the /tmp/ directory to their destinations in HDFS:


```
    hdfs dfs -put /tmp/parse_log.py /user/hive/
    Hdfs dfs -put /tmp/transactions.log /user/hive/warehouse/python-udf/transactions/
```




<p id="gdcalert19" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/image19.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert20">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/image19.png "image_tooltip")



### Step 3 - Connect to Hive via Beeline

We will now connect to HiveServer2 via Beeline to perform the rest of the work.  Execute the following to do so:


```
beeline -u jdbc:hive2://localhost:10000
```




<p id="gdcalert20" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/image20.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert21">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/image20.png "image_tooltip")



### Step 4 - Add file to Hive resources

Now at the beeline prompt, you will need to add the python script to the Hive resource pool.  This is done by executing the following:

ADD FILE hdfs://namenode/user/hive/parse_log.py;

This makes the python script available to be used by the cluster during the Mapreduce operations.



<p id="gdcalert21" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/image21.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert22">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/image21.png "image_tooltip")



### Step 5 - Create Database and Table

Still at the beeline prompt, execute the following commands to create a new database and table for the transactions log data:

CREATE DATABASE IF NOT EXISTS pythonudf;

CREATE EXTERNAL TABLE IF NOT EXISTS pythonudf.transactions

(

    logline STRING

)

ROW FORMAT DELIMITED

STORED AS TEXTFILE

LOCATION 'hdfs://namenode:8020/user/hive/warehouse/pythonudf/transactions';


### 

<p id="gdcalert22" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/image22.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert23">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/image22.png "image_tooltip")



### Step 6 - Create View from TRANSFORM Query

Now execute the following to create a view from a TRANSFORM query that utilizes the Python script to parse the log data:


    CREATE VIEW pythonudf.transactions_parsed AS


    SELECT


    TRANSFORM (


    logline)


    USING 'python parse_log.py'


     AS ip_address   


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



<p id="gdcalert23" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/image23.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert24">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/image23.png "image_tooltip")



### Step 7 - Select from New View

Finally here is an example SELECT statement you can execute to view some columns of the first five records:

SELECT ip_address, user_name, bank_id FROM pythonudf.transactions_parsed LIMIT 5;



<p id="gdcalert24" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/image24.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert25">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/image24.png "image_tooltip")


 > [Go back to Exercise 2](pages/exercise_two.md)

 > [Continue on to Exercise 3](pages/exercise_three.md)