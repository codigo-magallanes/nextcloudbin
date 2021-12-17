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


declare -ir fecha_INICIO=$(date +%s)
declare -r fecha_INICIO_F=$(date +%c)


# Archivos a eliminar
declare -r -a arr_ELIMINAR=( 'RARBG.to.nfo' 'TuMejorTorrent.url' 'www.DIVXATOPE.com.url' 'TUmejorTorrent.url' 'CompucaliTV.url'
'Descargas torrent Gratis Serieshd,Peliculas hd - pctnew.org.URL' 'httptumejortorrent.com.url' 'divxatope1.url'
'Importante leer !!!!!.txt' 'www.newpct1.com.url' 'www.newpct.com.url' 'DESCARGAS2020.url' 'TorrentRapid.url'
'Tumejortorrent.url' 'Descargas torrent Gratis Serieshd,Peliculas hd - Descargas2020.org.website' 'NewPct1.url'  'NEWPCT.url'
'TorrentLocura.url' 'DivxATope.url' 'DESCARGAS2020 ORG.url' 'PCTNEW ORG.url' 'PCTRELOAD COM.url' 'PCTNEW.url'
'EliteStream - Ver Series y Peliculas Online Gratis Completas HD.url'
'EliteTorrent - Descargar Peliculas y Series Torrent.url'
'GamesTorrents - Descargar Juegos Torrent Gratis.url'
'www.divxatope.com.url'
'www.tumejortorrent.com.url' )

## TEXTOS ##
declare -r txt_ALMOHADILLAS="#########"
declare -r txt_SEPARADOR="------------------------------------------------------------------------------------------"
declare -r txt_INICIO="Listado $(date +%F)"

## SALIDAS EXIT ##
# 2 -> 'Error en los argumentos'
# 3 -> 'No se encuentra la videoteca'
# 4 -> 'No se encuentra el respaldo'


## FUNCIONES ##
# USAGE #
CODIGO=$0

function f_usage {
    echo "uso: ${CODIGO##*/} [-b CADENA] [-c][-d][-h][-l][-t] [-o <origen>] [-p <pelicula>] [-a <año>] [-e <etiquetas>] [-g <grupo>]"
    echo "  -a <cadena>  año de estreno de la película"
    echo "  -b <cadena>  busca películas coincidentes con la cadena en la lista de respaldo."
    echo "  -c           compara el listado con los archivos del disco (duplicados.log)"
    echo "  -d           muestra el uso de disco de las películas"
    echo "  -e <cadena>  etiquetas identificativas del archivo a añadir al nombre."
    echo "  -g <grupo>  grupo donde se va a archivar la película"
    echo "  -h           muestra la ayuda"
    echo "  -i <cadena>  recupera películas desde el respaldo (Respaldo -> Videoteca)"
    echo "  -l           genera lista de respaldos (lista_respaldos.log)"
    echo "  -o <cadena>  archivo de video o directorio con la película que se va a clasificar"
    echo "  -p <cadena>  nombre de la película"
    echo "  -r <cadena>  respaldar videoteca"
    echo "  -s <cadena>  nombra los archivos del directorio en orden con -part1, -part2, part3..."
    echo "  -S <grupo>   crea enlaces simbólicos de un grupo a .DATA"
    echo "  -t           crea directorios para todos los archivos de video y los mete dentro"
    echo "  -x		 Busca duplicados de películas duales en otros grupos para su eliminación"
    echo "  -z           Crea un enlace simbólico a la película en el directorio especial para Zoe"
    echo "
Ejemplos:
$CODIGO -b '(2001)'     -> Muestra las películas de 2001.
$CODIGO -d              -> Muestra el uso de disco de la videoteca.
$CODIGO -h              -> Muestra esta ayuda
$CODIGO -o <video>      -> Crea un directorio del mismo nombre del video y lo mete dentro
$CODIGO -o ./dir_con_pelicula -p \"Nombre de la pelicula\" -a 1998 -e \"Drip 1080p\" -g dual
$CODIGO -r <grupo>	-> Copia de seguridad del grupo
"
}

function f_control {
 [[ -d $ruta_VIDEO ]] || echo "Videoteca no localizada"; EXIT 4;
}


function f_tiempo_pasado {
  local segundos=$(($(date +%s)-$fecha_INICIO))
  local minutos=$((segundos/60))
  local resto=$(($segundos-($minutos*60)))
  echo "$fecha_INICIO_F"
  echo "$minutos m. $resto s."
}



function f_enlaces_creados {
  while read peli
    do
#     echo "${peli##*/}" # archivo
#     [[ -f "$ruta_CINE/$dir_DATA/${peli##*/}" ]] && echo "${peli##*/}"
## Busca coincidencias en .DATA para cada archivo en el subdirectorio
      if [[ -f "$ruta_CINE/$dir_DATA/${peli##*/}" ]]; then
	## Busca enlaces simbólicos. Falta como saber si hay coincidencias
	find -L "$ruta_CINE/$dir_DATA" -samefile "$ruta_CINE/$dir_DATA/${peli##*/}" -exec echo "Encontrado: {}" \;
        find -L "$ruta_CINE/$dir_DATA" -samefile "$ruta_CINE/$dir_DATA/${peli##*/}" -printf "%T+\t%p\n"
# error ->        [[ (find -L "$ruta_CINE/$dir_DATA" -samefile "$ruta_CINE/$dir_DATA/${peli##*/}" -printf "%T+\t%p\n") ]] || echo "enlace no encontrado"
	SALIDA=${SALIDA}$(find -L "$ruta_CINE/$dir_DATA" -samefile "$ruta_CINE/$dir_DATA/${peli##*/}" -printf "%T+\t%p\n")"\n"
      fi
    done < <(find "$ruta_CINE/$opt_grupo/" -maxdepth 2 -mindepth 1 -type f | sort)
  echo -e "$SALIDA"
}

function f_crea_enlaces {
  f_enlaces_creados
}


# Lista de películas ya respaldadas:
function f_respaldo_cine {
  while read peli
    do
        dir_pelicula="${peli##*/}"
        respaldo="$dir_destino/$dir_pelicula"
        if [[ -d $respaldo ]]; then
          ls -ahQs1 "$respaldo" | tail -n +4 > "$ruta_LOGS/temp/_bak.log"
          ls -ahQs1 "$peli" | tail -n +4 > "$ruta_LOGS/temp/_ori.log"
#          if [[  $(diff -q "$ruta_LOGS/temp/_bak.log" "$ruta_LOGS/temp/_ori.log") ]]; then
	  if diff -q "$ruta_LOGS/temp/_bak.log" "$ruta_LOGS/temp/_ori.log" > /dev/null ; then
            printf "\n$txt_ALMOHADILLAS $dir_pelicula $txt_ALMOHADILLAS\n$peli\n" > "$ruta_LOGS/diffs/$dir_pelicula.log"
            echo "$respaldo" | cat "$ruta_LOGS/temp/_ori.log" - "$ruta_LOGS/temp/_bak.log" >> "$ruta_LOGS/diffs/$dir_pelicula.log"
          fi

        # Si no existe el directorio de la pélicula...
        # Muestro los datos del video y lo copio en el destino.
        # Por último calculo el tiempo transcurrido si todo ha ido bien.
        else
          f_eliminar_basura
          printf "\n$txt_ALMOHADILLAS $dir_pelicula $txt_ALMOHADILLAS\n"
          du -h "$peli"
          cp -brv "$peli" -t "$dir_destino"
          [[ $? ]] && f_tiempo_pasado; exit 0 || echo "$txt_ALMOHADILLAS Error copiando archivos $txt_ALMOHADILLAS" && tiempo_pasado && exit 1
        fi
    done < <(find "$dir_origen" -maxdepth 1 -mindepth 1 -type d | sort)
    echo "Todos los respaldos al día en $dir_origen"
}

function f_estructura_logs {
  [[ -d '$ruta_ARCHIVOS' ]] || mkdir -p "$ruta_ARCHIVOS"
}

function f_archivar_todo () {
  while read peli
    do
      local ext=${peli##*.}
      for fin in "${arr_VIDEOS[@]}"
        do
          if [[ "$fin" == "$ext" ]]; then  f_archivo "${peli##*/}"; fi
        done
    done < <(find ./ -maxdepth 1 -type f | sort)
}

# Crea un directorio con el nombre del argumento sin extensión
# Luego mueve el archivo (argumento) dentro del directorio creado
function f_archivo () {
  local dir_origen="${1%.*}"
  mkdir "$dir_origen"
  mv -vb "${1}" -t "$dir_origen"/
}

function f_dual {
  declare -r dir_actualizados="/home/pi/cine"
  declare -r dir_actualizados2="/var/media/Cine"
  while read peli
   do
    pelif=${peli##*/}
    f_buscar_actualizada "$dir_actualizados"
    f_buscar_actualizada "$dir_actualizados2"
   done < <(find "$dir_actualizados/[dual]" -maxdepth 1 -type d | sort )
}

function f_buscar_actualizada {
    for grupo in $arr_ACTUALIZADAS
     do
      while read actualizado
       do
        f_peli_actualizada "$actualizado"
       done < <(find "$1/$grupo/" -iname "$pelif" | sort )
     done
}

function f_peli_actualizada {
    read -p "¿Eliminar película obsoleta? Si/no: " read_OBSOLETA
    read_obsoleta=${read_OBSOLETA:=si}
    obsoleta=${read_obsoleta,,}
    [[ "$obsoleta" == "si" ]] && echo "aquí borro el duplicado: $1"
}

# Recorre cada grupo de la videoteca buscando directorios con películas (arr_DUPES)
# Busca en los respaldos archivos de video con el mismo nombre que los directorios de la videoteca
# Copia el nombre de los archivos encontrados en la lista 'duplicados.log'
function f_dupes {
  [[ ! -d $ruta_CINE ]] && echo "Sin acceso a la videoteca" && exit 3 || echo "Accediendo a la videoteca"
  [[ ! -d $ruta_RESPALDO ]] && echo "Respaldos no localizados" && exit 4 || echo "Accediendo a los respaldos"
  declare -i i=0
  echo $(date +%F) > $log_DUPES
  for dir in $arr_DUPES
  do
    while read peli
     do
       pelif=${peli##*/}
       if [[ $i -eq 0 ]]
       then
         echo "Escaneando videoteca: $pelif" # El primer resultado es el directorio principal
         echo "$txt_ALMOHADILLAS $pelif $txt_ALMOHADILLAS" >> $log_DUPES
       else
         while read file
         do
            peso=$(stat -c '%s' "$file" | numfmt --to=iec)
            echo "$peso: $dir / $pelif" >> $log_DUPES
         done < <(find $ruta_RESPALDO -type f -iname "${pelif}*" | sort)
       fi
       i=1
     done < <(find "$ruta_CINE/$dir" -maxdepth 1 -type d | sort )
     i=0
  done
}

function f_lista {
  echo "$txt_INICIO" > "$log_LISTA"
  for grupo in $arr_GRUPOS
    do
      while read peli
        do
          pelif=${peli##*/}
          if [[ $i -eq 0 ]]; then
            echo "Directorio de búsqueda: $pelif"
#           directorio="$pelif"
            echo $txt_SEPARADOR >> "$log_LISTA"
            echo "$txt_ALMOHADILLAS $grupo $txt_ALMOHADILLAS" >> "$log_LISTA"
          else
            echo "$pelif" >> "$log_LISTA"
            ls -Qsh "$peli" > "$ruta_ARCHIVOS$dir/$pelif.log"
          fi
        i=1
    done < <(find "$ruta_RESPALDO/$grupo" -maxdepth 1 -type d | sort | uniq)
    i=0
  done
}

function f_uso_disco {
 sudo du -h -d 1 $ruta_CINE
}

function f_buscar_dupes {
    read -p "¿Buscar archivos duplicados? Si/no: " read_dupes
    dupes=${read_dupes:=si}
    dupes=${read_dupes,,}
    [[ "$dupes" == "si" ]] && fdupes -rd "$dir_origen" "$dir_pelicula"
}

## Elimina los archivos del directorio de origen con nombres incluidos en el array '$arr_ELIMINAR'
function f_eliminar_basura {
  for basura in "${arr_ELIMINAR[@]}"
    do
      [[ -f "$dir_origen$basura" ]] && rm -v -- "$dir_origen$basura"
    done
}

## Mueve los subdirectorios a destino sin modificar el contenido
function f_conservar_subdirectorios {
  find "$dir_origen"  -mindepth 1 -maxdepth 1 -type d -exec mv -b -t "$dir_pelicula"/ {} \;
}

## Busca archivos de vídeo y los renombra y mueve al directorio de destino
# Si no se añade el argumento 'readarray -t' la salida de cada elemento del array lleva al final de la línea unos caracteres que impide que se pueda seleccionar el achivo para renaombrarlo.
# mv: no se puede efectuar `stat' sobre 'nombre_del_archivo.avi'$'\n': No existe el fichero o el directorio
function f_mover_archivos {
  for ext in "${arr_VIDEOS[@]}"
    do
      declare -a array
      readarray -t array < <(find "$dir_origen" -maxdepth 1 -type f -iname "*.$ext" | sort)
      local nuevo="${dir_pelicula}/${pelicula}.${ext}"
     # En el caso de que solo haya un archivo de vídeo:
      if [[ ${#array[@]} -eq 1 ]]; then
	local archivo_DATA="${ruta_CINE}/${dir_DATA}/${pelicula}.${ext}"
	mv -vb "${array[0]}" "${archivo_DATA}"
	[[ $opt_zoe ]] && ln "${archivo_DATA}" "${ruta_CINE}/${dir_ZOE}/"
 	ln "${archivo_DATA}" "${dir_pelicula}/"
      fi
      if [[ ${#array[@]} -gt 1 ]]; then
        declare post=-part
        declare -i i=1
	for elemento in "${array[@]}"; do
	  ln "${elemento}" "${ruta_CINE}/${dir_DATA}/${pelicula}${post}${i}.${ext}"
	  mv -vb "$elemento" "${dir_pelicula}/${pelicula}${post}${i}.${ext}"
	  ((i++))
	done
      fi
    done
}

## Lee los archivos que quedan en el directorio y los compara con las extensiones de 'arr_EXTENSIONES'
#  Si hay una coincidencia renombra el archivo y lo mueve al '.DATA'
#  Luego crea un enlace simbólico del archivo en 'dir_pelicula'
#function f_extensiones {
function f_temporal {
  readarray -t archivos < <(find "$dir_origen" -maxdepth 1 -type f | sort)
  for archivo in "${archivos[@]}"; do
    echo "->$archivo"

#echo "${archivo}" | grep "${arr_EXTENSIONES[@]}" && echo "'¡COINCIDE!"

for ext in "${arr_EXTENSIONES[@]}"; do
  echo "${archivo}" | grep -m 1 -e "$ext" && echo "coincide con ${ext}" && break
done

  done
}

## Mueve otros archivos (no incluídos en el array de extensiones de vídeo)
function f_mover_otros_archivos {
#  local portada=front
#  find "$dir_origen" -maxdepth 1 -type f -iname "*${portada}.jpg" -exec mv -b -- {} "$dir_pelicula/${pelicula}.jpg" \;
  for extension in "${arr_EXTENSIONES[@]}"
    do
      local nuevo="$dir_pelicula/$pelicula$extension"
      local enlace="$ruta_Cine/$dir_DATA/${pelicula}${extension}"
      find "$dir_origen" -maxdepth 1 -type f -iname "*$extension" -exec mv -b -- {} "${nuevo}" \;
      ln "${nuevo}" "${enlace}"
    done
}

function f_falta_grupo {
  echo "Grupo no asignado. Repite el comando añadiendo el parámetro '-g <GRUPO>'"
  exit 0
}

# Genera el nombre de archivo y asigna ruta del directorio de destino
function f_nombra_enlace {
# Asigna el argumento '-p $opt_pelicula' a la variable 'pelicula_base'.
# Si existe el argumento '-a $opt_anyo' se añade a la variable.
  pelicula_base="${opt_pelicula:-${dir_origen}}${opt_anyo:+ (${opt_anyo})}"

# Modifica el directorio de destino según el grupo (-g XXX). Si no existe grupo llama a la función f_falta_grupo
  [ -n "$opt_grupo" ] && dir_pelicula="$ruta_CINE/$opt_grupo/$pelicula_base" || f_falta_grupo

# Asigna las etiquetas y el grupo a la variable 'etiquetas'.
  etiquetas="${opt_etiquetas:+$opt_etiquetas}${opt_grupo:+$opt_grupo}"

# Asigna los valores anteriores a la variable 'pelicula'
  pelicula="$pelicula_base${etiquetas:+ $etiquetas}"
}

function f_extension_peli () {
  extension="${opt_origen##*.}"
}

function f_crea_enlace {
  f_nombra_enlace
  extension="${opt_origen##*.}"
  mkdir "$dir_pelicula"
  ln "$opt_origen" "$dir_pelicula"/"$pelicula"."$extension"
 # Mueve el archivo a .DATA
  mv "$opt_origen" "$ruta_CINE/$dir_DATA/$pelicula.$extension"
 # Opción para guardar un enlace simbólico en 'Zoe'
 [ $opt_zoe ] ln "$opt_origen" "$ruta_CINE"/"$ruta_ZOE"/"$pelicula"."$extension"
}


## Genera los grupos del nombre de archivo y el directorio para la película
# $dir_pelicula
# pelicula = $dir_pelicula + $etiquetas
function f_pelis {
# Si '$opt_origen' es un archivo crea un directorio y mete el archivo dentro.
# Si '$opt_origen' es un directorio guarda el argumento como directorio 'origen'.
  [ -f "$opt_origen" ] && f_archivo "$opt_origen" && exit 0 || dir_origen="$opt_origen"

  dir_pelicula="${opt_pelicula:-${dir_origen}}${opt_anyo:+ (${opt_anyo})}"
  etiquetas="${opt_etiquetas:+$opt_etiquetas}${opt_grupo:+$opt_grupo}"
  pelicula="$dir_pelicula${etiquetas:+ $etiquetas}"
  [ -n "$opt_grupo" ] && dir_pelicula="$ruta_CINE/$opt_grupo/$dir_pelicula"

}

## Crea el directorio de la película
# En el caso de que ya exista comprueba si la película está duplicada
function f_directorio {
  if [[ ! -d "$dir_pelicula" ]]
    then
      mkdir -v "$dir_pelicula"
      echo "Directorio ${dir_pelicula} creado."
    else
      echo "El directorio de destino ya existe: $dir_pelicula"
      ls -ahl "$dir_pelicula"
      f_buscar_dupes
      read -p "¿Continuar moviendo el archivo $pelicula en este directorio? Si/no: " read_continuar
      continuar=${read_continuar,,}
      [[ "$continuar" == "no" ]] && exit 2
    fi
}

## PARÁMETROS ##
while getopts :cdhlstxza:b:e:g:i:o:p:r:S: option
  do
    case "${option}"
    in
      a) opt_anyo=$OPTARG;;
      b) grep -i "${OPTARG[*]}" $log_LISTA || echo "No hay resultados."
        exit 0;;
      c) f_dupes
        wait $!
        echo "cat $log_DUPES"
        cat "$log_DUPES"
        exit 0;;
      d) f_uso_disco
        exit 0;;
      e) opt_etiquetas=$(printf '[%s]' ${OPTARG[*]});;
      g) opt_grupo="[$OPTARG]";;
      h) f_usage
	exit 0;;
      i) dir_origen="$ruta_RESPALDO/[$OPTARG]"
         dir_destino="$ruta_CINE/[$OPTARG]"
	 f_control_grupo
	 f_eliminar_basura
	 f_respaldo_cine
	 exit 0;;
      l) f_lista
        exit 0;;
      o) opt_origen=${OPTARG};;
      p) opt_pelicula="${OPTARG%/*}";;
      r) dir_destino="$ruta_RESPALDO/[$OPTARG]"
         dir_origen="$ruta_CINE/[$OPTARG]"
         f_control_grupo
         f_eliminar_basura
         f_respaldo_cine
	 exit 0;;
      s) opt_split=true;;
      S)opt_grupo="[$OPTARG]"
	f_crea_enlaces
	exit;;
      t) f_archivar_todo
        exit 0;;
      x) f_dual
	exit 0;;
      z) opt_zoe=true;;
      \?) echo "ERROR: argumento no aceptado en este programa"
        f_usage
	exit 2;;
      :) echo "ERROR: no se recibió el argumento correctamente"
	f_usage
	exit 2;;
    esac
  done

[[ -z $1 ]] && echo "ERROR: al menos debes elegir el directorio de origen u otras opciones." && f_usage && exit 2
# [[ -v 1 ]] && echo "ERROR: al menos debes elegir el directorio de origen u otras opciones." && f_usage && exit 2

# Genera el nombre del directorio y de la peli
  f_pelis
# Crea el directorio de destino dentro del grupo
  f_directorio
# Elimina archivos basura del directorio de origen
  f_eliminar_basura
# Mueve los subdirectorios en origen al direcrorio de destino
  f_conservar_subdirectorios
# Mueve los archivos de vídeo y los renonbra
  f_mover_archivos
# Renombra y mueve archivos con extensiones o cadenas determinadas en sus nombre
  f_mover_otros_archivos

# Borra el directorio (vacío) de origen
  rmdir -v "$dir_origen"
# Muestra el contenido del directorio de destino
  ls -ahl "$dir_pelicula"

# Función de test para nuevas tareas
# f_temporal
