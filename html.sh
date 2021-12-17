#!/bin/bash

# Genera el código de una página html

## USO ##
# Dirigir la salida del programa a un archivo nuevo:
# ./html.sh > info.html

# Se puede desarrollar para generar documentos que se abren en el navegador y luego se pueden guardar como pdfs
# Luego se puede abrir la página con:
# firefox -new-window test.html
# libreoffice --writer test.html

title="System Information for"

cat <<- _EOF_
<html>
  <head>
    <title>
      $title $HOSTNAME
    </title>
  </head>

  <body>
    <h1>$title $HOSTNAME</h1>
  </body>
</html>
_EOF_
