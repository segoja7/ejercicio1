#!/bin/bash

if [ "$(whoami)" != "root" ]; then
  echo "Necesitas otro usuario"
  exit 1
else
  echo "usuario validado: $(whoami)"
fi
#################################
password_mariadb=""
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
                echo $password_mariadb 
                sudo apt update -y
                sudo apt install $i -y
        else
                echo "el paquete: $i, no esta instalado"
                echo "Instalando $i"
                sudo apt update -y
                sudo apt install $i -y
        fi
done
echo $password_mariadb 
