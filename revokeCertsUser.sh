

USER_PATH=$1 #usuario al que se le va a revocar algún certificado
COMMUNITY_PATH=$2 #revocamos el certificado activo para esa comunidad
EXEUSER_PATH=$3	#gestor que realizara la acción

if [ $COMMUNITY_PATH = all ];
then
	echo 'obtenemos los certificados activos del miembro'
	sh certsActivosMember.sh $USER_PATH $EXEUSER_PATH > comuACT.txt
	
	maxCont=$(cat comuACT.txt | wc -l) 
	cont=2	

	while [ $cont -le $maxCont ];do

		COM=$(sed -n $cont,$cont\p comuACT.txt)		
		
		echo 'USE DigIdCom ;\nSELECT serialNumber from DigIdCom.certificado where (revocado='\'n\'') and (serialNumber= ANY (SELECT serialNumber from DigIdCom.es_propietario_de where (ID='\'$USER_PATH\'') and (serialNumber= ANY (SELECT serialNumber from DigIdCom.emite where serialNumber_int = ANY (SELECT serialNumber_int from DigIdCom.certifica where nombreComunidad='\'$COM\'')))));' > snTEMP.sql		
		
		cat snTEMP.sql >> snTotTEMP.sql		

		cont=$(($cont+1))
	done
	
	echo 'Obtenemos los numeros de serie de los certificados a revocar'
	mysql -u $EXEUSER_PATH -p < snTotTEMP.sql > snTotTEMP.txt

	sed '/serialNumber/d' snTotTEMP.txt > snTot.txt
	cat snTot.txt
	maxCont2=$(cat snTot.txt | wc -l) 
	cont2=1	
	cont3=2
	while [ $cont2 -le $maxCont2 ];do

		SNcomplete=$(sed -n $cont2,$cont2\p snTot.txt)
		SN=$(sed -n $cont2,$cont2\p snTot.txt |tail -c6 | head -c4)
		COM2=$(sed -n $cont3,$cont3\p comuACT.txt)			

		openssl ca -config /DigIdCom/ca/intermediate$COM2/openssl$COM2.cnf -revoke /DigIdCom/ca/intermediate$COM2/newcerts/$SN.pem -crl_reason unspecified

		openssl ca -config /DigIdCom/ca/intermediate$COM2/openssl$COM2.cnf -gencrl -out  /DigIdCom/ca/intermediate$COM2/crl/$SN.crl		
		
		echo 'USE DigIdCom ;\nUPDATE DigIdCom.certificado set revocado = '\'s\'' where (serialNumber = '\'$SNcomplete\'');' > updateCertTEMP.sql	
		
		cat updateCertTEMP.sql >> updateCertTotTEMP.sql		

		cont2=$(($cont2+1))
		cont3=$(($cont3+1))
	done
	
	echo 'Actualizamos estado del certificado en la base de datos'

	mysql -u $EXEUSER_PATH -p < updateCertTotTEMP.sql
	
	rm updateCertTotTEMP.sql snTotTEMP.* snTEMP.* comuACT.* snTot.*

else
	echo 'USE DigIdCom ;\nSELECT serialNumber from DigIdCom.certificado where (revocado='\'n\'') and (serialNumber= ANY (SELECT serialNumber from DigIdCom.es_propietario_de where (ID='\'$USER_PATH\'') and (serialNumber= ANY (SELECT serialNumber from DigIdCom.emite where serialNumber_int = ANY (SELECT serialNumber_int from DigIdCom.certifica where nombreComunidad='\'$COMMUNITY_PATH\'')))));' > snTEMP.sql

	echo 'Obtenemos información de la base de datos'

	mysql -u $EXEUSER_PATH -p < snTEMP.sql > snTEMP.txt

	SN=$(sed -n 2,2p snTEMP.txt |tail -c6 | head -c4)

	openssl ca -config /DigIdCom/ca/intermediate$COMMUNITY_PATH/openssl$COMMUNITY_PATH.cnf -revoke /DigIdCom/ca/intermediate$COMMUNITY_PATH/newcerts/$SN.pem -crl_reason unspecified

	openssl ca -config /DigIdCom/ca/intermediate$COMMUNITY_PATH/openssl$COMMUNITY_PATH.cnf -gencrl -out  /DigIdCom/ca/intermediate$COMMUNITY_PATH/crl/$SN.crl

	SNcomplete=$(sed -n 2,2p snTEMP.txt) 

	echo 'USE DigIdCom ;\nUPDATE DigIdCom.certificado set revocado = '\'s\'' where (serialNumber = '\'$SNcomplete\'');' > updateCertTEMP.sql

	echo 'Actualizamos estado del certificado en la base de datos'

	mysql -u $EXEUSER_PATH -p < updateCertTEMP.sql

	rm snTEMP.* updateCertTEMP.*

fi










