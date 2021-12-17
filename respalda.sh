#!/bin/bash
# respalda.sh
# CRE: 13-03-2019

# http://wiki.gonzalezjerez.com/doku.php?id=wiki:programacion:codigo:sh:respalda

# v2.5
#Añadida opción de respaldo en PWD

# v2.4
# Mod: 07 Dic. 2019
# Variables trasladadas a archivo de configuración ~/bin/config/pi.conf

# v2.3
# MOD: 06/12/2019
# Modificadas rutas a respaldos y archivo de configuración
# Añadido código para la creación de directorio local de respaldo si no existe.
# Nuevo directorio en servidor ftp con el "hostname" del equipo que manda el respaldo.

# v2.2
# MOD: 21/06/2019

## USO
# Programa guiado de copia de seguridad del directorio desde donde se ejecuta, con respaldo en servidor ftp.
# Debe existir directorio: $HOME/respaldos

## NOTAS
# BZ2 PARA UNA MAYOR COMPRESIÓN, PERO TARDA MÁS EN CREAR EL ARCHIVO
# TGZ PARA COMPRESIÓN MÁS RÁPIDA PERO MENOR RATIO DE COMPRESIÓN

## PENDIENTE ##
#

## VARIABLES IMPORTADAS ##
# ~/bin/config/pi.conf
# _RESPALDOS
# _FECHA
# _FECHAyHORA
# RA_RESPALDOS
# DIR_RESPALDOS_FTP

## FUNCIONES
function sino() {
if [[ "$_continuo" = "no" ]]; then
    printf "\nCancelando operación. Saliendo del programa\n";
    exit 0;
fi
}

function f_crea_directorios_ftp() {
    local r
    local a
    let equipo=`hostname`
    r=$equipo/${PWD#*/}
    while [[ "$r" != "$a" ]]; do
        a=${r%%/*}
        printf "mkdir $a\n"
        printf "cd $a\n"
        r=${r#*/}
    done
}

# Excluyo archivos ocultos, como .claves.incl
function f_comprimir() {
    #sleep 5
    printf "Ejecutando... tar $excluir $opciones $_RESPALDO_AHORA.$ext .\n"
    tar $excluir $opciones $_RESPALDO_AHORA.$ext .
    exit 0
}

function f_subir_ftp() {
    printf "Conectando a $FTP_SERVIDOR...\n"
    ftp -n -i $FTP_SERVIDOR <<-EOF
    user $FTP_USUARIO $FTP_CLAVE
    cd $DIR_RESPALDOS_FTP
    $(f_crea_directorios_ftp)
    put $_RESPALDO_AHORA.$ext $FECHAyHORA$_PLUS.$ext
    bye
EOF
    wait $!
}


clear

## INCLUDES ##
declare -r RA_CONFIG="$HOME/bin/config/pi.conf"
. $RA_CONFIG
. $RA_CLAVESYUSUARIOS

printf "Vas a realizar una copia de seguridad del directorio actual:\n$PWD\n[Si/no]: "
read -n 2 _continuo
sino

printf "Incluir archivos ocultos.[Si/no]: "
read -n 2 _ocultos
#excluir="--exclude='./tests' --exclude='./respaldos' --exclude='./js/*.jpg' "
excluir="--exclude='*/.*'"
if [ "$_ocultos" == "no" ]; then
  _PLUS=$_NO
  excluir="$excluir--exclude='*/.*' "
fi

printf "Guardar respaldo en la ruta actual.[Si/no]: "
read -n 2 _local
if [[ "$_local" != "no" ]]; then
  _RESPALDO_AHORA=$_LOCAL_AHORA
fi

_RESPALDO_AHORA=$_RESPALDO_AHORA$_PLUS

printf "\nElije formato de compresión:\n [1] tgz\n [2] bz2\n"
read -n 1 _formato
if [[ "$_formato" != 2 ]]; then
 ext="tgz"
 opciones="-cpvzf"
else
 ext="bz2"
 opciones="-cpvjf"
fi


printf "\nCreando archivo de respaldo...\n"
f_comprimir

printf "Subir respaldo: ($_RESPALDO_AHORA.$ext)\n a servidor $FTP_SERVIDOR [Si/no]: "
read -n 2 _continuo
[[ "$_continuo" != "no" ]] && f_subir_ftp

printf "\n"
read -n 2 -p "Eliminar archivo local de repaldo [Si/no]: " _continuo

printf "\n"
if [[ "$_continuo" == "no" ]]; then
    read -p "Escribe nombre del respaldo para guardar: " _renombrar
    mv $_RESPALDO_AHORA.$ext $RA_RESPALDOS/$FECHA.-$_renombrar.$ext
else
    printf "Elimino archivo de respaldo local...\n"
    rm $_RESPALDO_AHORA.$ext
fi
