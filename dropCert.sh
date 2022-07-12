#!/bin/bash

ID=$1
COMMUNITY=$2
EXE_PATH=$3


if [ $COMMUNITY = all ];
then

	echo 'SELECT serialNumber FROM DigIdCom.es_propietario_de WHERE ID ='\'$ID\'';' > consulTEMP.sql
	
else

	echo 'SELECT serialNumber FROM DigIdCom.emite WHERE (serialNumber_int = ANY(SELECT serialNumber_int FROM DigIdCom.certifica WHERE nombrecomunidad = '\'$COMMUNITY\'') )AND (serialNumber = ANY(SELECT serialNumber FROM DigIdCom.es_propietario_de WHERE ID='\'$ID\''));' > consulTEMP.sql

fi
echo 'Localizamos los certificados en la base de datos'
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

echo 'Eliminamos los certificados de la base de datos'
mysql -u $EXE_PATH -p < completeDrop.sql

rm drop.sql completeDrop.sql consulTEMP.*
