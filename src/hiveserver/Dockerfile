FROM tbytnar/portable-hadoop:hive-base

COPY startup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/startup.sh

EXPOSE 10000
EXPOSE 10002

CMD startup.sh