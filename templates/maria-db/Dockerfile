FROM mariadb:10.3

USER root

ADD conf/* /etc/mysql/conf.d/
ADD certs/mysqld*.pem /etc/certs/
COPY docker-entrypoint.sh /usr/local/bin/

RUN ln -sf /usr/local/bin/docker-entrypoint.sh /entrypoint.sh \
 && chmod -R +r /etc/certs \
 && chmod -R +r /etc/mysql/conf.d \
 && chmod +rx  /usr/local/bin/docker-entrypoint.sh 

ENV MYSQL_ROOT_PASSWORD toor
ENV MYSQL_ROOT_HOST %



 
