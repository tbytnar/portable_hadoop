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