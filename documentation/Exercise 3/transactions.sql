-- Add the python script to the Hive resource pool
ADD FILE hdfs://namenode:8020/user/hive/parse_log.py;

-- Create a new database
CREATE DATABASE IF NOT EXISTS pythonudf;

-- Create the table (single column) for transactions log file
CREATE EXTERNAL TABLE IF NOT EXISTS pythonudf.transactions
(
    logline STRING
)
ROW FORMAT DELIMITED
STORED AS TEXTFILE
LOCATION 'hdfs://namenode:8020/user/hive/warehouse/pythonudf/transactions';

-- Using the python UDF, parse the logline column from the previous table into a formatted table
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


SELECT ip_address, user_name, bank_id FROM pythonudf.transactions_parsed LIMIT 5;