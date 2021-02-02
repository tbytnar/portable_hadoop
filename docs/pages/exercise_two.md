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


```
    docker cp "documentation/Exercise 2/drivers.csv" hive-server:/tmp
    docker cp "documentation/Exercise 2/trucks.txt" hive-server:/tmp
```




<p id="gdcalert11" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/image11.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert12">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/image11.png "image_tooltip")



```
    NOTE: In the previous exercise you uploaded the data files to the datanode.  Here we are uploading directly to the hive-server for efficiency.
```



### Step 2 - Adding flat files to HDFS

Now that the flat files have been uploaded to the container, you will need to connect to its shell.  To do so execute the following in your terminal window:


```
    docker-compose exec hive-server bash
```


Now inside the container, you can validate the flat files are there by running this:


```
    ls /tmp/
```




<p id="gdcalert12" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/image12.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert13">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/image12.png "image_tooltip")


Next you’ll need to create a directory structure for the new database and its tables.  Execute the following commands:


```
    hdfs dfs -mkdir -p /user/hive/flatfiles/
    hdfs dfs -put /tmp/trucks.txt /user/hive/flatfiles/
    hdfs dfs -put /tmp/drivers.csv /user/hive/flatfiles/
    NOTE: In the previous exercise you uploaded the files into a directory on HDFS which specified the database and table names in its path.  This time we are uploading the files to a static folder and will be loading the data into the Hive tables with a different method.  It's important to remember that there are several ways to accomplish the same goal.
```



### Step 3 - Create the new database

Now with the data files in HDFS we can connect to HiveServer using beeline:


```
    beeline -u jdbc:hive2://localhost:10000
```


Next you’ll need to create a database to house the new tables.  Execute the following to do so:


    _CREATE DATABASE truckingco;_


    

<p id="gdcalert13" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/image13.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert14">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/image13.png "image_tooltip")


For convenience the CREATE TABLE sql statement is stored in the source files located here: “_documentation/Exercise 2/trucks.sql  and drivers.sql.”_  Copy or type the entire statements and then paste it into the terminal so it is executed at the beeline prompt. <code><em><span style="text-decoration:underline;">NOTE</span>: You will see "No rows affected…" when the statement completes.  Also pay close attention to the SERDEPROPERTIES in trucks.sql.  We are using a regex string here to parse the log file's format and convert the text into structured data. Also note that we have instead created empty tables and loaded data into them using the LOAD DATA command. </em></code>


    

<p id="gdcalert14" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/image14.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert15">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/image14.png "image_tooltip")



    

<p id="gdcalert15" ><span style="color: red; font-weight: bold">>>>>>  gd2md-html alert: inline image link here (to images/image15.png). Store image on your image server and adjust path/filename/extension if necessary. </span><br>(<a href="#">Back to top</a>)(<a href="#gdcalert16">Next alert</a>)<br><span style="color: red; font-weight: bold">>>>>> </span></p>


![alt_text](images/image15.png "image_tooltip")



### Step 4 - Joining the data together in a SQL query

Now that the tables have been created and data has been loaded, we can execute a SQL query against them to join the data:


```
    SELECT * FROM truckingco.drivers d JOIN truckingco.trucks t ON d.location = t.location WHERE d.id = 4;
```


Now you are able to report on all the truck logs for Camron Stevens.  Feel free to play around further with more complex SQL queries.  Once you are finished, exit beeline by typing: !q

Last take a look at the directory structure inside of HDFS by executing the following commands:


```
    hdfs dfs -ls /user/hive/warehouse/
        NOTE: truckingco.db was automatically created after executing the CREATE DATABASE command
    hdfs dfs -ls /user/hive/warehouse/truckingco.db/
    NOTE: drivers and trucks were automatically created after executing the CREATE EXTERNAL TABLE commands
```
