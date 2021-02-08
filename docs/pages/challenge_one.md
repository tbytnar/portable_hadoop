## Challenge One

Scenario: An error has caused corruption in a banking companies general ledger application.  They need you to assist with discovering information about the missing transactions.  You have been given three data files.  One contains records for all banks at the company, another contains records for all bank managers.  The last file is an Apache log file which lists all of the transactions for a specific period of time as well as the ID of the bank which performed the transaction.   

Example Log Record (Bank ID, 22, in red text):


> 13.200.56.57 - funk2780 [13/Jan/2021:21:05:35 +0000] "POST /bandwidth/scale/action-items HTTP/1.0" 503 <span style="color:red"><b>22</b></span> "https://www.centralwhiteboard.net/enterprise/world-class/revolutionary/mesh" "Mozilla/5.0 (Windows NT 5.2; en-US; rv:1.9.0.20) Gecko/1956-26-03 Firefox/35.0"



Using the source data files provided in Documentation\Challenge1, import the data into HDFS, create a single database with three tables.  Then write SQL queries that will answer the following questions (Check your answers in Appendix 3):



1. Which bank manager had the most transactions in the timeframe recorded?
2. Which bank recorded the least number of transactions?
3. What is the total number of transactions for these three bank locations:
    1. Chamical
    2. Washington
    3. Verd


 > [Go back to Exercise 2](exercise_two.md)

 > [Continue on to Exercise 3](exercise_three.md)