#!/bin/bash

# PRIMERA VERSIÓN
# Declaro un array asociativo
# Cargo los datos en el array (las acciones por día)
# Declaro una función que:
#	Crea una variable cuyo valor es el elemento del array del día en curso (no su valor)
#	Imprimo el texto donde se lee el valor del elemento del array a través de la nueva variable
# Ejecuto la función

declare -A dios   # Imprescindible declarar el array asociativo

dios[lun]="creó el Día y la Noche"
dios[mar]="separó el Cielo y el Mar"
dios[mié]="creó las plantas"
dios[jue]="creó el Sol y la Luna"
dios[vie]="creó los peces y las aves"
dios[sáb]="creó los animales y los humanos"
dios[dom]="descansó"

function Dios () {
 var_fecha="dios[$(date +%a)]"
 echo "Tal día como hoy Dios ${!var_fecha}."
}
Dios

# SEGUNDA VERSIÓN
# Dios sin arrays
# Todo se ejecuta desde dentro de una nueva función (function dios())
# Crea una variable por cada día de la semana con su valor correspondiente
# Luego obtiene la abreviatura del día de la semana y elimina los acentos para que coincidan con el nombre de las variables anteriores
# A la vez crea una variable cuyo valor es el nombre de la variable del día actual.
# Imprime los datos con el valor de la última variable, que llama a la variable del día.
# Ejecuto la función

function dios () {
  var_lun="creó el Día y la Noche"
  var_mar="separó el Cielo y el Mar"
  var_mie="creó las plantas"
  var_jue="creó el Sol y la Luna"
  var_vie="creó los peces y las aves"
  var_sab="creó los animales y los humanos"
  var_dom="descansó"

  var_fecha="var_$(date +%a | tr 'áéíóúÁÉÍÓÚ' ' a e i o u A E I O U' | tr -d ' ')"

  printf "El %s Dios %s.\n" $(date +%A) "${!var_fecha}"
}

dios

# VERSIÓN DEFINITIVA
# Creo un array con los valores en orden de domingo a sábado
# Imprimo el valor del elemento correspondiente según el día de la semana con $(date +%u)

accion=( "descansó"
	"creó el Día y la Noche"
	"separó el Cielo y el Mar"
	"creó las plantas"
	"creó el Sol y la Luna"
	"creó los peces y las aves"
	"creó los animales y los humanos"
	)

printf "El %s Dios %s.\n" $(date +%A) "${accion[$(date +%u)]}"
