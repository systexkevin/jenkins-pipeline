FROM ubuntu:22.04

RUN apt update
RUN apt-get -y install wget
RUN apt-get -y install tzdata
RUN apt-get -y install apache2
RUN echo "Dockerfile Test on Apache2" > /var/www/html/index.html

EXPOSE 8080
CMD ["/usr/sbin/apachectl", "-D", "FOREGROUND"]
