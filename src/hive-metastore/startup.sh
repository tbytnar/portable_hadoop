# PostgreSQL install and configure
service postgresql start
sudo -u postgres psql -c "CREATE USER hive WITH PASSWORD 'hive';"
sudo -u postgres psql -c "CREATE DATABASE metastore;"

/opt/hive/bin/schematool -dbType postgres -initSchema --verbose
/opt/hive/bin/hive --service metastore