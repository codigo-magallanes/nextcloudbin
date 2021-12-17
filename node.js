#!/bin/bash
# node.sh
# CRE: 01/04/2020

#DIR='/home/pi/inmo'
sleep 5
cd /home/josea/proyectos/nodejs/amo
sleep 5
echo $PWD >> /home/josea/bin/logs/crontab.log
node ./bin/www
