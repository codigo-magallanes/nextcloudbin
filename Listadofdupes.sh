#!/bin/bash
# Creado: 19/07/2017
# MOD: 08/10/2019

## FUNCIONAMIENTO
#  Crea un listado de duplicados preparados para ser eliminados o respaldados
#  Parámetro 1 - Carpeta con ofiginales
#  Parámetro 2 - Carpeta con duplicados que se quieren eliminar
#  Parámetro 3 - Nombre del listado

## DEPENDENCIAS
# RespaldarListado.sh

## PARÁMETROS
originales=$1
duplicados=$2
lista=$3

## OTRAS CONFIGURACIONES
listado="$lista.fdupes"
listado_noeliminar="$listado.noeliminar"
listado_sort="$listado.sort"

printf "\nActualizando fechas de modificación de archivos en %s...\n" $duplicados
find $duplicados/* -print -exec touch {} \;
printf "\nFechas de modificación actualizadas para %s\n" $duplicados
fdupes -rfA $originales $duplicados > $listado
printf "\nListado de duplicados generado: %s" $listado
wait $!
sleep 1
printf "\nArchivos duplicados en %s que no serán modificados:\n" $originales
sort $listado | uniq | grep -v '^$' | grep ^$originales/ | tee $listado_noeliminar
wait $!
sleep 1
printf "\nOrdenando y filtrando archivos a ser respaldados:\n "
sleep 1
sort $listado | uniq | grep -v '^$' | grep -v ^$originales/ | tee $listado_sort
wait $!

# printf "\nLlamando a programa de respaldo: RespaldarListado.sh\n"
# sleep 1
# RespaldarListado.sh $listado_sort


