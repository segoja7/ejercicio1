#!/bin/bash

if [ "$(whoami)" != "root" ]; then
  echo "Necesitas otro usuario"
  exit 1
else
  echo "usuario validado: $(whoami)"
fi
#################################
password_mariadb=""
repo="bootcamp-devops-2023"
paquetes="git apache2 php pwgen mariadb-server"

#cloning repo
if [ "$(ls | grep $repo)" = "$repo" ]; then
        echo "el repo ya existe, nada para hacer"
else
        echo "el repo no esta clonado"
        echo "clonando..."
        git clone https://github.com/roxsross/$repo.git
        cd $repo
        git checkout clase2-linux-bash
fi
##update paquetes
for i in $paquetes; do
        if dpkg -l | grep -q "$i"; then
                echo "el paquete: $i, ya esta instalado"
        elif [ "mariadb-server" = "$i" ]; then
                echo "el paquete: $i, no esta instalado"
                echo "parametrizando $i"
                password_mariadb=$(pwgen 25 1 --symbols)
                echo "Instalando $i"
                echo "mysql-server mysql-server/root_password password $password_mariadb" | sudo debconf-set-selections
                echo "mysql-server mysql-server/root_password_again password $password_mariadb" | sudo debconf-set-selections
                export DEBIAN_FRONTEND="noninteractive"
                #echo $password_mariadb
                sudo apt update -y
                sudo apt install $i -y
                ##Iniciando la base de datos
                systemctl start mysql
#                systemctl status mysql
                ###Configuracion de la base de datos
                mysql -e "CREATE USER codeuser@localhost IDENTIFIED BY '$password_mariadb'";
                mysql -e "SELECT User FROM mysql.user";
                mysql -e "CREATE DATABASE devopstravel";
                mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'codeuser'@'localhost'";
                mysql -e "FLUSH PRIVILEGES;";
                #ejecutar script
                mysql < database/devopstravel.sql
        elif [ "php" = "$i" ]; then
                echo "el paquete: $i, no esta instalado"
                echo "parametrizando $i"
                echo "Instalando $i"
                sudo apt update -y
                sudo apt install $i libapache2-mod-php php-mysql -y
                echo "<?php phpinfo(); ?>" > /var/www/html/index.php
        elif [ "apache2" = "$i" ]; then
                echo "el paquete: $i, no esta instalado"
                echo "parametrizando $i"
                echo "Instalando $i"
                sudo apt update -y
                sudo apt install $i -y
                ##Iniciando servidor apache
                systemctl start apache2
                systemctl enable apache2
#                systemctl status apache2
                mv /var/www/html/index.html /var/www/html/index.hmtl.bkp
                echo "moviendo app-295devops-travel a /var/www/html/"
                mv app-295devops-travel /var/www/html/
        else
                echo "el paquete: $i, no esta instalado"
                echo "Instalando $i"
                sudo apt update -y
                sudo apt install $i -y
        fi
done
#testing status 200
if [ "$(curl -s -o /dev/null -w "%{http_code}" http://localhost/index.php)" != "200" ]; then
        echo "El sitio no esta ok"
        exit 1
else
        echo "El sitio esta ok"
fi




