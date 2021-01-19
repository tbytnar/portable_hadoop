FROM tbytnar/portable-hadoop:hive-base

RUN apt-get update && apt-get install -y postgresql postgresql-contrib libpostgresql-jdbc-java net-tools curl netcat sudo

ADD startup.sh /startup.sh
ADD postgresql.conf /etc/postgresql/10/main/postgresql.conf
ADD pg_hba.conf /etc/postgresql/10/main/pg_hba.conf
RUN chmod a+x /startup.sh

EXPOSE 10000/tcp
EXPOSE 10002/tcp
EXPOSE 5432/tcp

CMD /startup.sh