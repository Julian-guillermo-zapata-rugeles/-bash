#!/usr/bin/env bash
#
# EL objetivo de este script es notificar la conexión u desconexión de algún dispositivo de red
#
# Dependencias :
#              debian/ubuntu/mint/base-debian
#              sudo apt-get install nmap
#              sudo apt-get install libnotify.bin
#              sudo apt-get install sox (adicional si desea sonido play -n synth 1 para emitir sonido en consola )
#
#
DEMONIO_CRONTAB=false    # $true si usará en CRONTAB
INTERVALO_BUSQUEDA=30  # El intervalo está dado en segundos
CONTADOR_ITERACIONES=0
ACTIVE_DEVICES=0
NEW_DEVICES=0

if [[ !$DEMONIO_CRONTAB ]]; then
    #Primer ejecución del programa en modo NO CRONTAB creará un primer checksum y reportará
    clear
    notify-send "Iniciando seguimiento cada $INTERVALO_BUSQUEDA segundos"
    echo "+ Iniciando script  (creando checksum) " > temp_devices.tmp
    touch diff_compare
    md5sum temp_devices.tmp | awk {'print $1'} > checksum

    #Inicio de ciclo infinito , Puede interrumpir en cualquier momento CTRL + C
    #Recomendaciones : use tiempos en promedio 60 segundos , nmap tarda aproximadamente 5-8 segundos

    while (( !$DEMONIO_CRONTAB )); do
        # Alerta ! si usará este script en el demonio CRONTAB por favor modifque DEMONIO_CRONTAB=$true
        cat banner
        echo "+ $ACTIVE_DEVICES Conectados en este momento \n"
        cat temp_devices.tmp
        echo "+ Esperando $INTERVALO_BUSQUEDA +- 10 segundos para refresar"
        start_compare=$(cat checksum) # comparación inicial del script


        ##IMPORTANTE: COMANDO NMAP , USE EL DE SU PREFERENCIA
        sudo nmap -sn 192.168.1.1/24 | grep MAC | awk {'print $3'} > temp_devices.tmp
        #--------------------------------------------------------------------------


        md5sum temp_devices.tmp | awk {'print $1'} > checksum


        last_compare=$(cat checksum) # comparación final del script luego de refresar con nmap
        if [[ $last_compare !=  $start_compare ]]; then
          echo "+ Cambios detectados"
          NEW_DEVICES=$(wc -l temp_devices.tmp | awk {'print $1'})
          if (( $NEW_DEVICES > $ACTIVE_DEVICES)); then
            #Nuevo dispositivo en red
            dispositivo=$(diff diff_compare temp_devices.tmp | awk {'print $2'} | sed ':a;N;$!ba;s/\n/ /g')
            notify-send "$dispositivo se conectó a la red"
          fi
          if (( $NEW_DEVICES < $ACTIVE_DEVICES)); then
            #Nuevo dispositivo en red
            dispositivo=$(diff diff_compare temp_devices.tmp | awk {'print $2'} | sed ':a;N;$!ba;s/\n/ /g')
            notify-send "$dispositivo se desconectó de la red"
          fi
        fi
        ACTIVE_DEVICES=$(wc -l temp_devices.tmp | awk {'print $1'})
        sleep $INTERVALO_BUSQUEDA
        cp temp_devices.tmp diff_compare
        clear
    done
fi
