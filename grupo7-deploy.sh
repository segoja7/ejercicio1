#!/bin/bash

if [ "$(whoami)" != "root" ]; then
  echo "Necesitas otro usuario"
  exit 1
else
  echo "usuario validado: $(whoami)"
  
  paquetes="git apache2 php mariadb-server pwgen"
  for i in $paquetes; do
    if dpkg -l | grep -q "$i"; then
      echo "el paquete: $i, ya esta instalado"
    else
      echo "el paquete: $i, no esta instalado"
      echo "Instalando $i"
      sudo apt update -y
      sudo apt install $i -y
      #Parametrizando mariadb.
      password_mariadb=$(pwgen 25 1 --symbols)
      echo "mysql-server mysql-server/root_password password $password_mariadb" | sudo debconf-set-selections
      echo "mysql-server mysql-server/root_password_again password $password_mariadb" | sudo debconf-set-selections 
      #testing
      export DEBIAN_FRONTEND="noninteractive"
      echo $password_mariadb 
      mysql_secure_installation
    fi
  done
fi

password_mariadb=$(pwgen 25 1 --symbols)
echo $password_mariadb
