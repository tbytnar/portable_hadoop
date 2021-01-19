FROM tbytnar/portable-hadoop:hadoop-base

HEALTHCHECK CMD curl -f http://localhost:8042/ || exit 1

ADD run.sh /run.sh
RUN chmod a+x /run.sh

RUN apt update && apt install -y python

EXPOSE 8042

CMD ["/run.sh"]
