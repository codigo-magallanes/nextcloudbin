#! /bin/bash
# /home/pi/bin/subirtodo.sh

# USO
# Usa ncftp a no ser que se pase "ftp" como parámetro
# Sube directorios de manera recursiva

# CONFIGURACIÓN
HOST='ftp.servage.net'
USER='josea223'
PASSWD='patata01'
DIR='www.paraguay/www.grupoeuroga.com/contabilidad'
LOCAL='/home/pi/bin'
HORA=$(date +%H%M)

cd $LOCAL

# SOLO SI SE LLAMA CON EL PARAMETRO "ftp"
if [ "$1" == "ftp" ]; then
# -i -> elimina la necesidad de confirmar la subida de archivos
# -n ->
# -v -> 
ftp -inv $HOST << END_SCRIPT
quote USER $USER
quote PASS $PASSWD
binary
cd $DIR
mkdir $(date +%Y)
cd $(date +%Y)
mkdir $(date +%m)
cd $(date +%m)
mkdir $(date +%d)
cd $(date +%d)
mkdir $(date +%H)
cd $(date +%H)
mput -r *
quit
END_SCRIPT
END 0
fi

# Sube recursivamente archivos y carpetas
ncftp -u $USER -p $PASSWD $HOST << END_SCRIPT
binary
cd $DIR
mkdir $(date +%Y)
cd $(date +%Y)
mkdir $(date +%m)
cd $(date +%m)
mkdir $(date +%d)
cd $(date +%d)
mkdir $HORA
cd $HORA
mput -r *
quit
END_SCRIPT
