#!/bin/bash

COMMUNITY=$1
EXE_PATH=$2

echo 'SELECT serialNumber FROM DigIdCom.emite WHERE serialNumber_int = (SELECT serialNumber_int FROM DigIdCom.certifica WHERE nombreComunidad = '\'$COMMUNITY\'');' > consulTEMP.sql

echo 'Localizamos los certificados emitidos por la CA_Intermedia en la base de datos'
mysql -u $EXE_PATH -p < consulTEMP.sql > consulTEMP.txt

maxCont=$(cat consulTEMP.txt | wc -l)
cont=2
	#bucle
	while [ $cont -le $maxCont ];do

		CERT=$(sed -n $cont,$cont\p consulTEMP.txt)	
		
		echo 'SET foreign_key_checks = 0; \nDELETE FROM DigIdCom.es_propietario_de WHERE serialNumber = '\'$CERT\''; \nDELETE FROM DigIdCom.emite WHERE serialNumber = '\'$CERT\''; \nDELETE FROM DigIdCom.certificado WHERE serialNumber = '\'$CERT\'';' > drop.sql

		cat drop.sql >> completeDrop.sql
		
		cont=$(($cont+1))
	done

echo 'SELECT serialNumber_int FROM DigIdCom.certifica WHERE nombreComunidad = '\'$COMMUNITY\'';' > SNint.sql

echo 'Obtenemos el Numero de Serie del certificado de CA_intermedia'
mysql -u $EXE_PATH -p < SNint.sql > SNint.txt

CERT2=$(sed -n 2,2p SNint.txt)

echo 'DELETE FROM DigIdCom.ca_int WHERE serialNumber_int='\'$CERT2\''; \nDELETE FROM DigIdCom.certifica WHERE serialNumber_int='\'$CERT2\''; \nDELETE FROM DigIdCom.crea WHERE serialNumber_int='\'$CERT2\'';' >> completeDrop.sql

echo 'Eliminamos los certificados de la base de datos'
mysql -u $EXE_PATH -p < completeDrop.sql

rm drop.sql completeDrop.sql consulTEMP.* SNint.* 
