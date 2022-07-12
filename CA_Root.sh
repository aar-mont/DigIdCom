#!/usr/bin/env bash
EXEUSER=$1

set -e 

CA_PATH=ca

mkdir $CA_PATH $CA_PATH/certs $CA_PATH/crl $CA_PATH/newcerts $CA_PATH/private $CA_PATH/privateMember 

cd $CA_PATH
cp /DigIdCom/cnf/openssl.cnf .

chmod 700 private
chmod 700 privateMember
touch index.txt
echo 0001 > serial
echo 0001 > crlnumber

###############################################################################################################

openssl genrsa -out private/ca_root.key.pem 2048	#llave privada
chmod 400 private/ca_root.key.pem

################################################################################################################

openssl req -config /DigIdCom/cnf/openssl.cnf -key private/ca_root.key.pem -new -sha256 -x509	-days 5000 -extensions v3_ca 	-subj "/C=ES/ST=Castilla_y_Leon/L=Valladolid/O=DigIdCom/OU=DigIdCom/CN=DigIdCom_RootCA"	-out certs/ca_root.cert.pem

echo 'Autoridad certificadora raiz creada'

################################################################################################################

		#insertamos en la base de datos	
		
echo 'Cargando la información de la Autoridad certificadora en base de  datos'

openssl x509 -noout -text -in certs/ca_root.cert.pem > certTEMP.txt

nombreOrg=DigIdCom
ubicacion=Valladolid_Spain

serialNum=$(sed -n 5,5p certTEMP.txt | cut -c 13-100) #extraemos el numero de serie 
valido=s
fechaFin=$(cat certTEMP.txt | grep 'Not After' | cut -c 25-100) #extraemos numero de serie

echo 'INSERT INTO DigIdCom.ca_root(nombreOrg_cert, ubicacion, serialNumber_root, valida_root, fechaFin_root) VALUES ('\'$nombreOrg\'', '\'$ubicacion\'', '\'$serialNum\'', '\'$valido\'', '\'$fechaFin\'');' > chargeTEMP.sql

mysql -u $EXEUSER -p < chargeTEMP.sql

rm chargeTEMP.sql certTEMP.txt

