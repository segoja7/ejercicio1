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
      mysql_secure_installation --host=::1 --port=3333 --password=$password_mariadb --user=testing
      #testing
      echo $password_mariadb
    fi
  done
fi
