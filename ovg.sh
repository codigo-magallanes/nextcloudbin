#!/bin/bash
# ~/bin/ovg.sh
# V0.1
# CRE: 07/11/2021
# ORIGINAL: ~/bin/registra.sh

## CHANGELOG ##


## PROCESO ##
# Busca archivos de vídeo de más de 5GB y los mueve, con su directorio contenedor a 'masde5GB', 'masde10GB' y 'masde25GB'


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



## SALIDAS EXIT ##
# 4 -> 'No se encuentra el directorio con los vídeos'


function f_control {
 [[ -d $ruta_VIDEO ]] || echo "Videoteca no localizada"; EXIT 4;
}


function f_pelis_grandes {
  echo "Moviendo películas grandes (+5GB)"
  while read peli
    do
        mv -iv "${peli%/*}" -t "$ruta_5GB"
    done < <(find "$ruta_VIDEO" -maxdepth 2 -mindepth 1 -type f -size +5G)
}

function f_pelis_enormes {
  echo "Moviendo películas enormes (+10GB)"
  while read peli
    do
        mv -iv "${peli%/*}" -t "$ruta_10GB"
    done < <(find "$ruta_VIDEO" -maxdepth 2 -mindepth 1 -type f -size +10G)
}

function f_pelis_gigantes {
  echo "Moviendo películas gigantes (+25GB)"
  while read peli
    do
        mv -iv "${peli%/*}" -t "$ruta_25GB"
    done < <(find "$ruta_VIDEO" -maxdepth 2 -mindepth 1 -type f -size +25G)
}

f_pelis_gigantes
f_pelis_enormes
f_pelis_grandes

