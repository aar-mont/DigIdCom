#!/bin/bash

MEMBER=$1
EXEUSER_PATH=$2

echo 'SELECT serialNumber,revocado FROM DigIdCom.certificado WHERE serialNumber = ANY (SELECT serialNumber FROM DigIdCom.es_propietario_de WHERE ID = '\'$MEMBER\'');' > consultaTEMP.sql

mysql -u $EXEUSER_PATH -p < consultaTEMP.sql

rm consultaTEMP.sql
