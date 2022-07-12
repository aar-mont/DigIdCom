COMMUNITY=$1 #revocamos el certificado activo para esa comunidad
EXEUSER_PATH=$2	#gestor que realizara la acción

echo 'USE DigIdCom ;\nSELECT serialNumber from DigIdCom.emite where serialNumber_int = ANY (SELECT serialNumber_int FROM DigIdCom.certifica WHERE nombreComunidad = '\'$COMMUNITY\'');' > snCertsTEMP.sql

echo 'Obtenemos información de los certificados emitidos por CA Intermedia'
mysql -u $EXEUSER_PATH -p < snCertsTEMP.sql > snCertsTEMP.txt 

maxCont=$(cat snCertsTEMP.txt | wc -l)
cont=2

while [ $cont -le $maxCont ];do

	SNcomplete=$(sed -n $cont,$cont\p snCertsTEMP.txt | tail -c6 | head -c4)	
	SN=$(sed -n $cont,$cont\p snCertsTEMP.txt)

	openssl ca -config /DigIdCom/ca/intermediate$COMMUNITY/openssl$COMMUNITY.cnf -revoke /DigIdCom/ca/intermediate$COMMUNITY/newcerts/$SNcomplete.pem -crl_reason unspecified

	openssl ca -config /DigIdCom/ca/intermediate$COMMUNITY/openssl$COMMUNITY.cnf -gencrl -out  /DigIdCom/ca/intermediate$COMMUNITY/crl/$SNcomplete.crl		
		
	echo 'UPDATE DigIdCom.certificado set revocado = '\'s\'' where (serialNumber = '\'$SN\'');' > updateTEMP.sql		
		
	cat updateTEMP.sql >> updateTotTEMP.sql		

	cont=$(($cont+1))
done

echo 'UPDATE DigIdCom.ca_int set valida = '\'n\'' where (nombreCom_int = '\'$COMMUNITY\'') and (valida = '\'s\'');' >> updateTotTEMP.sql

echo 'Obtenemos información de la CA intermedia'
mysql -u $EXEUSER_PATH -p < updateTotTEMP.sql

echo 'USE DigIdCom ;\nSELECT serialNumber_int from DigIdCom.certifica where nombreComunidad = '\'$COMMUNITY\'';' > snCA_intTEMP.sql

echo 'Obtenemos el numero de serie del certificado de la CA_Int'
mysql -u $EXEUSER_PATH -p < snCA_intTEMP.sql > snCA_intTEMP.txt

SN=$(sed -n 2,2p snCA_intTEMP.txt | head -c1)

openssl ca -config /DigIdCom/ca/openssl.cnf -revoke /DigIdCom/ca/newcerts/0$SN.pem -crl_reason unspecified #REVOCAMOS LA CA_INT

openssl ca -config /DigIdCom/ca/openssl.cnf -gencrl -out  /DigIdCom/ca/crl/0$SN.crl

rm snCA_intTEMP.* updateTEMP.* updateTotTEMP.* snCertsTEMP.*

