#!/bin/bash

#   Julián Guillermo zapata rugeles 2020
#
#   verificar mediante free y pipes la memoria usada. generar una alerta cuando la memoria está en un nivel crítico
#   dependencias : notify-send para alerta gráfica
#      debian :
#              sudo apt-get install libnotify.bin
#
#   integración crontab
#         */1 * * * * export DISPLAY=:0 && paht_to_script
#         ejemplo cron cada minuto
#
#  USO:
#       MEMORIA_CRITICA representa el nivel de memoria mínimo para la alerta
#       modifique a conveniencia el valor entre 0 a 100 %
#
#
# 1 funcionalidad : Alerta cuando la memoria RAM alcanza niveles altos de ocupación 2020 septiembre 7
# 2 funcionalidad : Al alcanzar algún límite crítico de memoria a traves de top se podrá procesar la salida
#                   para mostrar los procesos con más consumo de memoria en el momento de ejecución del script o
#
#
MEMORIA_CRITICA=15           # 0 A 100 , ALERTA MEMORIA CUANDO ALCANCE  % "MEMORIA_CRITICA " MINIMA
PROCESOS_MAYOR_CONSUMO=5     # determina el numero de procesos con mayor consumo que mostrará el script

memoriaTotal=$(free --mega | grep Mem |awk '{print $2}');
memoriaDisponible=$(free --mega | grep Mem |awk '{print $7}')
alerta=$(( (memoriaTotal*MEMORIA_CRITICA)/100 ))
clear # limpia terminal
echo "-----------------------------------------------------------"
echo "Actual $memoriaTotal megabytes";
echo "Disponible $memoriaDisponible megabytes";
echo "Nivel alerta : cuando baje de $alerta megabytes";
echo "Procesos con mayor consumo :\n"
top -b -n 1 | grep $(whoami) | head -n $PROCESOS_MAYOR_CONSUMO # procesos de mayor consumo del usuario
echo "-----------------------------------------------------------\n"

if [ "$memoriaDisponible" -lt "$alerta" ]; then
        # Agrega aquí tus comandos en caso que la memoria descienda por debajo del nivel crítico
        #
        echo "La memoria disponible es poca $memoriaDisponible Megabytes";

        # Comando notify-send para generar Alerta memoria
        export DISPLAY=:0 && notify-send " Nivel de memoria crítico ( $memoriaDisponible Megabytes )" # alerta gráfica

      else

        # ---------------------else -----------------------------
        # Agrega aquí tus comandos en caso de que la memoria disponible esté en niveles aceptados
        # Ejemplo : salida a un log y luego gráficar el uso de memoria / dia. Etc
        echo "Todo en orden $memoriaDisponible Megabytes";

fi
