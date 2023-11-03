#!/bin/bash

if [ "$(whoami)" != "root" ]; then
  echo "Necesitas otro usuario"
  exit 1
else
  echo "usuario validado: $(whoami)"
  
  paquetes="git apache2 php mariadb-server"
  for i in $paquetes; do
    if dpkg -l | grep -q "$i"; then
      echo "el paquete: $i, ya esta instalado"
    else
      echo "el paquete: $i, no esta instalado"
      echo "Instalando $i"
      sudo apt update -y
      sudo apt install $i -y      
    fi
  done
fi
