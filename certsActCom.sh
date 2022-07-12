#!/bin/bash

COMMUNITY=$1
EXEUSER_PATH=$2

echo 'SELECT * FROM DigIdCom.es_propietario_de WHERE serialNumber= ANY(SELECT serialNumber from DigIdCom.emite WHERE serialNumber_int= (SELECT serialNumber_int FROM DigIdCom.certifica WHERE nombreComunidad = '\'$COMMUNITY\'')) and serialNumber = ANY (SELECT serialNumber from DigIdCom.certificado WHERE revocado ='\'n\'');' > consultaTEMP.sql

mysql -u $EXEUSER_PATH -p < consultaTEMP.sql

rm consultaTEMP.sql



