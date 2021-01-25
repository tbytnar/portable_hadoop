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

load data inpath '/user/hive/flatfiles/wnv_human_cases.csv' into table wnv_cases;

create table wnv_cases_part(year string,week string,cases INT) PARTITIONED BY(county string);

set hive.exec.dynamic.partition.mode=nonstrict;

INSERT OVERWRITE TABLE wnv_cases_part PARTITION(county)
SELECT year,week,cases,county from  wnv_cases;
