#!/bin/bash
# ~/bin/cargaPelis.sh
# V0.1
# CRE: 07/11/2021
# ORIGINAL: ~/bin/ovg.sh

## CHANGELOG ##


## PROCESO ##
# Carga películas a una unidad con un máximo de peso total del directorio que la contiene


## ARGUMENTOS ##
# Acepta dos agumentos:
#	$1 ->	Megabytes máximos por directorio (Int)
#	$2 ->	Ruta del directorios de destino (String)


## EJEMPLOS ##
# cargaPelis.sh 1500 /media/josea/media1/.Videoteca/Cine/

## PENDIENTE ##
# Hacer lo mismo con 'rsync' y de esa manera poder mostrar los datos que se copiarán en realidad. Ahora hace un cálculo de lo que pesan todos los directorios seleccionados con el 'find'.

## DEPENDENCIAS ##


## VARIABLES ##
# Ruta a videoteca
declare -r ruta_VIDEO="./Selección"
# Unidad donde están almacenadas los respaldos de las películas
declare -r ruta_5GB="./masde5GB"
# Ubicación de los logs
declare -r ruta_10GB="./masde10GB"
# Directorio de almacenamiento de las películas con sus nombres originales
declare -r dir_25GB='./masde25GB'

# bytes
declare -i bytes=$1*1024*1024


## SALIDAS EXIT ##
# 4 -> 'No se encuentra el directorio con los vídeos'


function f_control {
 [[ -d $ruta_VIDEO ]] || echo "Videoteca no localizada"; EXIT 4;
}


function f_simulacion () {
  echo "Simulación de copia de películas  < $1 MB."
  while read peli
    do
        s=$(du -hsb "$peli"| cut -f1)
        
        if [[ $bytes -gt $s ]]; then
        	echo "${peli##*/}"
            	let i+=1
            	let b+=s
        fi
    done < <(find "$ruta_VIDEO" -maxdepth 1 -mindepth 1 -type d)
    
    echo "Total películas: $i"
    printf "Total datos a copiar: %'d GB. (%'d bytes)\n" "$(($b / 1024 / 1024 / 1024))" "$b"
}

function f_carga_pelis () {
  echo "Moviendo películas  < $1 MB."
  while read peli
    do
        s=$(du -hsb "$peli"| cut -f1)
        
        if [[ $bytes -gt $s ]]; then
              	let i+=1
            	let b+=s
            	echo "Copiando $i/$I"

        	echo "${peli##*/}"
        	cp -an "${peli}" -t "$2"
        	
        	printf "Copiados: %'d GB. de %'d GB. \n" "$(($b / 1024 / 1024 / 1024))" "$3"
        fi
    done < <(find "$ruta_VIDEO" -maxdepth 1 -mindepth 1 -type d)
}


i=0
b=0

f_simulacion "$1" "$2"


read -p "¿Copiar los datos seleccionados? Si/no: " read_continuar
      continuar=${read_continuar,,}
      [[ "$continuar" == "no" ]] && exit 2

B=$b
I=$i 
i=0
b=0

f_carga_pelis "$1" "$2" "$(($B / 1024 / 1024 / 1024))"

echo "Total películas: $i"
printf "Total datos copiados: %'d GB.\n" "$(($b / 1024 / 1024 / 1024))"
