# Práctica 16: Dockerizar una aplicación LAMP

Para esta práctica tendremos que crear un archivo Dockerfile en la cual crearemos nuestra imagen docker que tendrá una aplicación web LAMP. 

## Dockerfile

- Utilizaremos de imagen la versión de **ubuntu** que está etiquetada como **focal** - **FROM**
- Añadimos una etiqueta (OPCIONAL) - **LABEL**
- Añadimos la variable de entorno - **ENV**
- Ejecutaremos los comandos necesarios para la LAMP. Esta se dividirá en dos, una para instalación y otra para configuración. - **RUN**
- Añadimos el puerto (OPCIONAL) - **EXPOSE**
- Finalmente proporcionamos los valores para la ejecución de esta. - **CMD**

El resultado sería: 

```
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
```
Una vez terminado nuestro dockerfile proseguiremos con la configuración del archivo docker-compose.

## Docker Compose

Los resquisitos para este son: 

- MySQL
- phpmyadmin
- Apache

### Apache

Para la imagen apache a diferencia de las anteriores al no ser una imagen sacada de DockerHub sino que la imagen la creamos nosotros tendremos que hacer uso del **build** (**image** es para sacar las imagenes de DockerHub). Añadimos los puertos 80:80, que dependa de MySQL para conectarse, asignamos las redes frontend y backend y finalmente que reinicie en caso de fallar. 
```
 apache: 
        build: ./apache
        ports: 
            - 80:80
        depends_on: 
            - mysql
        networks: 
            - frontend-network
            - backend-network
        restart: always
```
Para phpmyadmin y mysql serán iguales a las ya hechas en anteriores prácticas pero con una pequeña diferencia dentro de MySQL. 

### MySQL

Dentro de **volumes** habrá que añadir una nueva línea que será para guardar los datos dentro de la base de datos. 

```
 mysql:
        image: mysql:5.7
        ports:
            - 3306:3306
        environment:
            - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
            - MYSQL_DATABASE=${MYSQL_DATABASE}
            - MYSQL_USER=${MYSQL_USER}
            - MYSQL_PASSWORD=${MYSQL_PASSWORD}
        volumes:
            - mysql_data:/var/lib/mysql
            - ./sql:/docker-entrypoint-initdb.d
        networks:
            - backend-network
        restart: always
```
Ya que sin eso los datos que añadiesemos a la base de datos no se guardarían porque no hay tablas. 

### phpmyadmin 

```
 phpmyadmin:
        image: phpmyadmin
        environment:
            - PMA_ARBITRARY=1
        ports:
            - 8080:80
        networks:
            - frontend-network
            - backend-network
        depends_on: 
            - mysql
        restart: always
```

Por último crearemos nuestro archivo oculto .env con las variables de nuestro docker-compose. 
