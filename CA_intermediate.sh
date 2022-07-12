
COMUNITY_PATH=$1
serialPath=$2
EXE_PATH=$3

#NO TOUCH
INTER_PATH=intermediate$COMUNITY_PATH
INTERKEY_PATH=inter$COMUNITY_PATH.key.pem
INTERCSR_PATH=inter$COMUNITY_PATH.csr.pem
INTERCERT_PATH=inter$COMUNITY_PATH.cert.pem
INTERCONF_PATH=openssl$COMUNITY_PATH.cnf
INTERVALUES_PATH="/C=ES/ST=Castilla_y_Leon/L=Valladolid/O=DigIdCom/OU=$COMUNITY_PATH/CN=DigIdCom_IntermediateCA_$COMUNITY_PATH" 

cd ca

mkdir -p $INTER_PATH $INTER_PATH/certs $INTER_PATH/crl $INTER_PATH/csr $INTER_PATH/newcerts $INTER_PATH/private 
chmod 700 $INTER_PATH/private
touch $INTER_PATH/index.txt
echo $serialPath > $INTER_PATH/serial
echo $serialPath > $INTER_PATH/crlnumber
###############################################################################################################

openssl genrsa -out $INTER_PATH/private/$INTERKEY_PATH 2048
chmod 400 $INTER_PATH/private/$INTERKEY_PATH

###############################################################################################################
cp /DigIdCom/cnf/$INTERCONF_PATH /DigIdCom/ca/$INTER_PATH

openssl req -config $INTER_PATH/$INTERCONF_PATH	 -new -sha256 -key $INTER_PATH/private/$INTERKEY_PATH -subj $INTERVALUES_PATH -out $INTER_PATH/csr/$INTERCSR_PATH

openssl ca -config openssl.cnf -extensions v3_intermediate_ca -days 5000 -batch -notext -md sha256 -in $INTER_PATH/csr/$INTERCSR_PATH -out $INTER_PATH/certs/$INTERCERT_PATH

cat $INTER_PATH/certs/$INTERCERT_PATH certs/ca_root.cert.pem > $INTER_PATH/certs/chain.cert.pem

chmod 444 $INTER_PATH/certs/chain.cert.pem

echo 'Autoridad certificadora '$INTER_PATH' creada'

##############################################################################################################

openssl x509 -noout -text -in $INTER_PATH/certs/$INTERCERT_PATH > certTEMP.txt
openssl x509 -noout -text -in certs/ca_root.cert.pem > certrootTEMP.txt
nombreCOM=$COMUNITY_PATH
ubicacion=Valladolid_Spain

serialNum=$(sed -n 4,4p certTEMP.txt | cut -c 24-100) #extraemos el numero de serie CA_intermediate
serialNumRoot=$(sed -n 5,5p certrootTEMP.txt | cut -c 13-100) #extraemos el numero de serie CA_Root

valido=s
miembros=0

fechaFin=$(cat certTEMP.txt | grep 'Not After' | cut -c 25-100) #extraemos fecha de expiración
fechaInic=$(cat certTEMP.txt | grep 'Not Before' | cut -c 25-100) #extraemos fecha de creación

echo 'INSERT INTO DigIdCom.ca_int(nombreCom_int, ubicacion_Com, serialNumber_int, valida, fechaFin_int) VALUES ('\'$nombreCOM\'', '\'$ubicacion\'', '\'$serialNum\'', '\'$valido\'', '\'$fechaFin\'');' > chargeTEMP.sql

echo 'INSERT INTO DigIdCom.comunidad(nombreComunidad, fechaCreacion, creador, numMiembros) VALUES ('\'$nombreCOM\'', '\'$fechaInic\'', '\'$EXE_PATH\'','\'$miembros\'' );' > charge2TEMP.sql

echo 'INSERT INTO DigIdCom.certifica(serialNumber_int, nombreComunidad) VALUES ('\'$serialNum\'', '\'$nombreCOM\'');' > charge3TEMP.sql

echo 'INSERT INTO DigIdCom.crea(serialNumber_root, serialNumber_int) VALUES ('\'$serialNumRoot\'', '\'$serialNum\'');' > charge4TEMP.sql

cat charge2TEMP.sql chargeTEMP.sql charge3TEMP.sql charge4TEMP.sql > completeTEMP.sql

mysql -u $EXE_PATH -p < completeTEMP.sql

rm chargeTEMP.sql charge2TEMP.sql charge3TEMP.sql charge4TEMP.sql completeTEMP.sql certTEMP.txt certrootTEMP.txt


















