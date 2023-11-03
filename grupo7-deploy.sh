#!/bin/bash

#check user id
if [ "$(whoami)" != "root" ]; then
  echo "Necesitas otro usuario"
  exit 1
else
  echo "El script se ejecutó con éxito."
  exit 0  
fi


