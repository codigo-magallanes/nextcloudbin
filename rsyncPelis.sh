#!/bin/bash
# ~/bin/rsyncPelis.sh
# V0.1
# CRE: 07/11/2021
# ORIGINAL: ~/bin/cargaPelis.sh

## CHANGELOG ##


## USO ##
# Carga películas con un máximo de peso total del directorio que la contiene

## PROCESO ##
# Recorre los subdirectorios del directorio desde el que se ejecuta el programa ->    done < <(find "$ruta_VIDEO" -maxdepth 1 -mindepth 1 -type d)
# Extrae el tamaño de cada subdirectorio ->	s=$(du -hsb "$peli"| cut -f1)



## ARGUMENTOS ##
# Acepta dos agumentos:
#	$1 ->	Megabytes máximos por directorio (Int)
#	$2 ->	Ruta del directorios de destino (String)


## EJEMPLOS ##
# rsyncPelis.sh 1500 /media/josea/media1/.Videoteca/Cine/

## PENDIENTE ##
# Buscar la manera de recuperar la cantidad de datos que se copiarán y no el total de datos de todos los directorios con tamaño menor al enviado como argumento


## DEPENDENCIAS ##


## VARIABLES ##
declare -r ruta_VIDEO='./'
declare -i bytes=$1*1024*1024

declare -r separador=' ### ### ### ### ### ### ### ### ### ### ###'
declare -r fecha="$(date +%F)"
declare -r log_LISTADO="listado_pelis.log"

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
        	echo "${peli##*/}" >> $log_LISTADO
            	let i+=1
            	let b+=s
            	out=$(rsync -anv "$peli" "$2" | grep "total size" | cut -d " " -f4 | sed 's/,//g')
            	let r+=out
        fi
    done < <(find "$ruta_VIDEO" -maxdepth 1 -mindepth 1 -type d)
    
    echo "\n$separador"
    echo "Total películas: $i"
    printf "Total datos a copiar: %'d GB. (%'d bytes)\n" "$(($b / 1024 / 1024 / 1024))" "$b"
    printf "Total datos a sincronizar: %'d GB.\n" "$(($r / 1024 / 1024 / 1024))"
    echo "$separador"
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
            	out=$(rsync -av "$peli" "$2" | grep "sent" | cut -d " " -f2 | sed 's/,//g')
            	let r+=out
        	
        	printf "Copiados: %'d GB. de %'d GB. \nTotal al final de la operación: %'d GB.\n" "$(($r / 1024 / 1024 / 1024))" "$(($b / 1024 / 1024 / 1024))" "$3"
        fi
    done < <(find "$ruta_VIDEO" -maxdepth 1 -mindepth 1 -type d)
}


i=0
b=0
r=0

f_simulacion "$1" "$2"


read -p "¿Copiar los datos seleccionados? Sí/no: " read_continuar
      continuar=${read_continuar,,}
      [[ "$continuar" == "no" ]] && exit 2

B=$b
R=$(($r / 1024 / 1024 / 1024))
r=0
i=0
b=0

f_carga_pelis "$1" "$2" "$R"

echo "Total películas: $i"
printf "Total datos copiados: %'d GB.\n" "$(($r / 1024 / 1024 / 1024))"
