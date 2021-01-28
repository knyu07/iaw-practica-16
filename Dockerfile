FROM ubuntu:focal
LABEL author="Pilar Ventura" 
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update \
    && apt install apache2 -y \
    && apt install php libapache2-mod-php php-mysql -y 

RUN apt install git -y \
    && cd /tmp \
    && git clone https://github.com/josejuansanchez/iaw-practica-lamp \
    && mv /tmp/iaw-practica-lamp/src/* /var/www/html \
    && sed -i 's/localhost/mysql/' /var/www/html/config.php \
    && rm /var/www/html/index.html

EXPOSE 80

CMD ["/usr/sbin/apachectl", "-D", "FOREGROUND"]
