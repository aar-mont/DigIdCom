#!/bin/bash

MEMBER=$1
EXEUSER_PATH=$2

echo 'SELECT nombreComunidad FROM DigIdCom.certifica WHERE serialNumber_int = ANY (SELECT serialNumber_int FROM DigIdCom.emite WHERE (serialNumber = ANY (SELECT serialNumber FROM DigIdCom.certificado WHERE revocado = '\'s\'')) AND (serialNumber = ANY (SELECT serialNumber FROM DigIdCom.es_propietario_de WHERE ID = '\'$MEMBER\'')));' > consultaTEMP.sql

mysql -u $EXEUSER_PATH -p < consultaTEMP.sql

rm consultaTEMP.sql

