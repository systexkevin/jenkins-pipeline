FROM ubuntu:numbat

RUN apt update && apt install -y wget
RUN apt -y install tzdata
RUN apt -y install apache2
RUN echo "Dockerfile Test on Apache2" > /var/www/html/index.html

EXPOSE 8080
CMD ["/usr/sbin/apachectl", "-D", "FOREGROUND"]
