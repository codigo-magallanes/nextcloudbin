#!/bin/bash
# /Video
# compila.sh

## USO
# Divide una compilación por piezas
# El primer paso es crear un archivo de texto con los detalles de cada sección
# Luego divide y nombra las secciones.
# Por último crea los enlaces simbólicos por grupo

DIR_=${PWD##*/}
F_ext="${DIR_}.txt"
VIDEO_ext="mkv"

# En caso de que ya exista el listado de archivos a concatenar..
[[ -f "${F_ext}" ]] && rm "${F_ext}"

for f in *; do
  echo file \'$f\' >> "${F_ext}"
done


while getopts ":e:" opt; do
  case ${opt} in
    e )
      VIDEO_ext=$OPTARG
      ;;
    \? )
      echo "Invalid option: $OPTARG" 1>&2
      ;;
    : )
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      ;;
  esac
done
shift $((OPTIND -1))

VIDEO_="../${DIR_}.${VIDEO_ext}"

ffmpeg -f concat -safe 0 -i "${F_ext}" -c copy "${VIDEO_}"
