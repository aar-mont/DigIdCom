
OWNER_PATH=$1 #identificador de miembro
COM_PATH=$2 #comunidad para la cual es el certificado
EXEUSER_PATH=$3 #usuario que inicia sesion en la base de datos

echo 'select nombreApellidos from DigIdCom.miembro where '\'$OWNER_PATH\''=ID;'> completeNAME.sql
echo 'Obteniendo información de la Base de Datos'
mysql -u $EXEUSER_PATH -p < completeNAME.sql > completeNAME.txt

NAME_PATH=$(sed -n 2,2p completeNAME.txt)

rm completeNAME.*

dir_interCA=intermediate$COM_PATH
config_PATH=intermediate$COM_PATH/openssl$COM_PATH.cnf
DATA_PATH="/C=ES/ST=Castilla_y_Leon/L=Valladolid/O=DigIdCom/OU=$COM_PATH/CN=$NAME_PATH"

cd ca

openssl req -config $config_PATH -new -sha256 -key privateMember/$OWNER_PATH.key.pem -subj $DATA_PATH -out $dir_interCA/csr/$OWNER_PATH.csr.pem

openssl ca -config $config_PATH -batch -days 1000 -notext -md sha256 -in $dir_interCA/csr/$OWNER_PATH.csr.pem -out $dir_interCA/certs/$OWNER_PATH.cert.pem

chmod 444 $dir_interCA/certs/$OWNER_PATH.cert.pem

####################################################################################################################

echo 'Cargando información en la base de datos'

openssl x509 -noout -text -in intermediate$COM_PATH/certs/$OWNER_PATH.cert.pem > certTEMP.txt
openssl x509 -noout -text -in intermediate$COM_PATH/certs/inter$COM_PATH.cert.pem > certIntTEMP.txt

serialNumber=$(sed -n 4,4p certTEMP.txt | cut -c 24-100) #extraemos el numero de serie
revocado=n
fechaFin=$(cat certTEMP.txt | grep 'Not After' | cut -c 25-100) #extraemos fecha de expiración

serialNumber_int=$(sed -n 4,4p certIntTEMP.txt | cut -c 24-100) #extraemos el numero de serie ca_intermediate

echo 'INSERT INTO DigIdCom.certificado(serialNumber, revocado, fechaFin) VALUES ('\'$serialNumber\'', '\'$revocado\'', '\'$fechaFin\'');' > chargeTEMP.sql

echo 'INSERT INTO DigIdCom.emite(serialNumber_int, serialNumber) VALUES ('\'$serialNumber_int\'', '\'$serialNumber\'');' > charge2TEMP.sql

echo 'INSERT INTO DigIdCom.es_propietario_de(ID, serialNumber) VALUES ('\'$OWNER_PATH\'', '\'$serialNumber\'');' > charge3TEMP.sql

echo 'UPDATE DigIdCom.comunidad SET numMiembros=numMiembros+1 WHERE nombreComunidad ='\'$COM_PATH\'';' > charge4TEMP.sql

cat chargeTEMP.sql charge2TEMP.sql charge3TEMP.sql charge4TEMP.sql > completeTEMP.sql

mysql -u $EXEUSER_PATH -p < completeTEMP.sql

rm chargeTEMP.sql charge2TEMP.sql charge3TEMP.sql charge4TEMP.sql completeTEMP.sql
