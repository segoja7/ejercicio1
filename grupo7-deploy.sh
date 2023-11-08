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
echo $password_mariadb
