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