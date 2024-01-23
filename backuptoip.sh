#!/bin/bash
#--------------------------------------------------------------------------------------------------------
# Autor: Alberto Valero Mlynaricova
# Fecha: 06/10/2023
#
# Descripción: Script que a partir de un archivo YAML lea las IPs de las máquinas a 
#              las que se le quiere enviar mediante SCP unas copias de seguridad.              diferentes.
#              Las copias están comprimidas en .tar.gz  
#--------------------------------------------------------------------------------------------------------

# Variables
backup="copia-$(date '+%d%m%Y').tar.gz"
usuario="usuario"
destino="/home/$usuario"
log="./backuptoip.log"

echo $(date) >> $log
# Uso del programa
if [ $# -ne 1 ]; then
  echo "Uso correcto: $0 <archivo YAML>"
  echo "backuptoip: uso incorrecto del programa" >> $log
  exit 2
fi

# Compresión de las rutas
echo "Creando directorio /opt/copia..." >> $log
mkdir /opt/copia &>> $log
for ruta in $(yq -r .copias[].ubicacion $1)
do
  echo "Copiando fichero $ruta a /opt/copia..." >> $log
  cp -r $ruta /opt/copia &>> $log
  echo "Comprimiendo /opt/copia..." >> $log
  tar -czf $backup /opt/copia &>> $log
done
echo "Borrando /opt/copia..." >> $log
rm -r /opt/copia

# Lectura de IPs y SCP
for ip in $(yq -r .servidores[].ip $1)
do
    echo "Enviando copia a: $ip" >> $log
    scp $backup $usuario@$ip: &>> $log
done
