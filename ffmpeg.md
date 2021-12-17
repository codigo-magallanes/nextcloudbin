# ffmpeg

## Concatenar

1. Creo un archivo con las secciones del vídeo:

```
for f in *.avi; do echo "file '$f'" >> partes.txt; done
```

2. Compruebo que las secciones están en el orden deseado:

```
cat partes.txt
```

3. Creo el nuevo archivo de vídeo:

```
ffmpeg -f concat -fflags +genpts -safe 0 -i partes.txt -c copy "<archivo de salida>"
```

## Resumen

Todo junto para copiar y pegar:

```
for f in *.avi; do echo "file '$f'" >> partes.txt; done
cat partes.txt
ffmpeg -f concat -fflags +genpts -safe 0 -i partes.txt -c copy "<archivo de salida>"
```

