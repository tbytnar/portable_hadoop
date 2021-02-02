## Exercise Five

Scenario:  You’ve been given a flat file dataset and have been asked to create a partitioned table in hive for the data.  


### Step 1 - Uploading Flat File Data

If you still have the terminal shell open from the previous exercise, feel free to reuse that.  If not please launch a new terminal window.

You’ll need to know the full path to the source file you wish to inject into the Docker container.  Once you have this, then execute the following command:


```
    docker cp "documentation/Exercise 5/wnv_human_cases.csv" hive-server:/tmp
```



    Once the command completes, your file has been injected into the /tmp/ directory on the datanode container


    

<p id="gdcalert25" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/image25.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert26">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/image25.png "image_tooltip")


Validate that the file has been injected by attaching to the container’s shell and viewing the contents of the /tmp/ directory


```
    docker-compose exec hive-server bash
    ls /tmp/
```



    

<p id="gdcalert26" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/image26.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert27">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/image26.png "image_tooltip")



### Step 2 - Adding Flat File to HDFS

If you are still attached to the datanode container’s shell, feel free to reuse that.  If not please attach to that using the following:


```
    docker-compose exec hive-server bash
```


Copy the source file from the /tmp/ directory to the flatfiles HDFS directory:


```
    hdfs dfs -put /tmp/wnv_human_cases.csv /user/hive/flatfiles/
```




<p id="gdcalert27" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/image27.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert28">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/image27.png "image_tooltip")


At this point we have completed our work in the datanode container.  You can now leave its shell prompt by executing the following:



    1. <code><em>exit</em></code>


### Step 3 - Create SERDE table for flat file data

We will now connect to HiveServer2 via Beeline to perform the rest of the work.  Execute the following to do so:


```
beeline -u jdbc:hive2://localhost:10000
```




<p id="gdcalert28" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/image28.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert29">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/image28.png "image_tooltip")


Now at the beeline prompt, copy and paste the following code to create a new SERDE table.

NOTE: We’re using the quoteChar setting here to remove the surrounding quotes for each of the cell values.


```
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


```
load data inpath '/user/hive/flatfiles/wnv_human_cases.csv' into table wnv_cases;
```




<p id="gdcalert29" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/image29.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert30">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/image29.png "image_tooltip")



### Step 4 - Create Partitioned Table and Load data

Now that we’ve loaded the data into a SERDE table, we can create a new partitioned table using the following:


    create table wnv_cases_part(year string,week string,cases INT) PARTITIONED BY(county string);

And finally we can load the data from the previously created SERDE table into the new partitioned table using this:


    set hive.exec.dynamic.partition.mode=nonstrict;


    INSERT OVERWRITE TABLE wnv_cases_part PARTITION(county)


    SELECT year,week,cases,county from  wnv_cases;



<p id="gdcalert30" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/image30.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert31">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/image30.png "image_tooltip")



### Step 5 - Inspect HDFS

Feel free to run any SQL commands you want against that table (do not drop the table).  Once you have finished exit beeline by executing:  !q

Now at the shell prompt, execute this command:

hdfs dfs -ls /user/hive/warehouse/wnv_cases_part

It’s clear to see here how Hive partitioning works within HDFS.  Each record is now organized in it’s own county’s directory as seen below:



<p id="gdcalert31" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/image31.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert32">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/image31.png "image_tooltip")
