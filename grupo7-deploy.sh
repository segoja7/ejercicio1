#!/bin/bash

if [ "$(whoami)" != "root" ]; then
  echo "Necesitas otro usuario"
  exit 1
else
  echo "usuario validado: $(whoami)"
fi
#################################
password_mariadb=""
repo="The-DevOps-Journey-101"
paquetes="git apache2 php pwgen mariadb-server"
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
                systemctl status mysql
                ###Configuracion de la base de datos
                mysql -e "CREATE USER grupo7@localhost IDENTIFIED BY '$password_mariadb'";
                mysql -e "SELECT User FROM mysql.user";
                mysql -e "CREATE DATABASE ecomdb";
                mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'grupo7'@'localhost'";
                mysql -e "FLUSH PRIVILEGES;";
                #ejecutar script
                mysql < db-load-script.sql

        elif [ "php" = "$i" ]; then
                echo "el paquete: $i, no esta instalado"
                echo "parametrizando $i"
                echo "Instalando $i"
                sudo apt update -y
                sudo apt install $i libapache2-mod-php php-mysql -y
        elif [ "apache2" = "$i" ]; then
                echo "el paquete: $i, no esta instalado"
                echo "parametrizando $i"
                echo "Instalando $i"
                sudo apt update -y
                sudo apt install $i -y
                ##Iniciando servidor apache
                systemctl start apache2
                systemctl enable apache2
                systemctl status apache2
                mv /var/www/html/index.html /var/www/html/index.hmtl.bkp
        else
                echo "el paquete: $i, no esta instalado"
                echo "Instalando $i"
                sudo apt update -y
                sudo apt install $i -y
        fi
done
#testing status 200
if [ "$(curl -s -o /dev/null -w "%{http_code}" http://localhost/lamp-app-ecommerce/#product-list)" != "200" ]; then
  echo "El sitio no esta ok"
  exit 1
else
  echo "El sitio esta ok"
fi

#cloning repo
if [ "$(ls | grep $repo)" = "$repo" ]; then
        echo "el repo ya existe, nada para hacer"
        exit 1
else
        echo "el repo no esta clonado"
        echo "clonando..."
        git clone https://github.com/roxsross/$repo.git
        echo "moviendo app a /var/www/html/"
        mv $repo/CLASE-02/lamp-app-ecommerce /var/www/html/
fi
