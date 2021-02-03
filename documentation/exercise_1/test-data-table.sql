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