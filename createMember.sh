#!/bin/bash

COMPLETENAME_PATH=$1 #Nombre y apellidos del miembro a registrar
NAME_PATH=$2 #ID del usuario que se creara
PASS_PATH=$3 #password para el usuario
TYPE_PATH=$4 #rol del usuario
EXEUSER_PATH=$5 #gestor que ejecuta el comando


echo 'create user '$NAME_PATH'@localhost identified by '\'$PASS_PATH\'';' > creadorTEMPORAL.sql

if [ $TYPE_PATH = miembro ];
then
	echo 'USE DigIdCom;\nINSERT INTO DigIdCom.miembro(nombreApellidos, ID) VALUES ('\'$COMPLETENAME_PATH\'', '\'$NAME_PATH\'');' > insertTEMPORAL.sql
	echo 'GRANT SELECT on 'DigIdCom'.'miembro' to '\'$NAME_PATH\''@localhost;\nGRANT SELECT on 'DigIdCom'.'gestor' to '\'$NAME_PATH\''@localhost;\nGRANT SELECT on 'DigIdCom'.'comunidad' to '\'$NAME_PATH\''@localhost;'> permisosTEMPORAL.sql
elif [ $TYPE_PATH = gestor ];
then
	echo 'USE DigIdCom;\nINSERT INTO DigIdCom.miembro(nombreApellidos, ID) VALUES ('\'$COMPLETENAME_PATH\'', '\'$NAME_PATH\'');\nINSERT INTO DigIdCom.gestor(nombreApellidos, ID) VALUES ('\'$COMPLETENAME_PATH\'', '\'$NAME_PATH\'');' > insertTEMPORAL.sql
	echo 'GRANT SELECT,INSERT,UPDATE,DELETE on 'DigIdCom'.'*' to '\'$NAME_PATH\''@localhost ;\nGRANT CREATE USER ON *.* to '\'$NAME_PATH\''@localhost WITH GRANT OPTION;'> permisosTEMPORAL.sql
	
else
	echo 'Rol no existente. Roles disponibles miembro y gestor'
fi

cat insertTEMPORAL.sql creadorTEMPORAL.sql permisosTEMPORAL.sql > completeTEMPORAL.sql
rm insertTEMPORAL.sql
rm creadorTEMPORAL.sql
rm permisosTEMPORAL.sql

mysql -u $EXEUSER_PATH -p <completeTEMPORAL.sql
rm completeTEMPORAL.sql

#generamos la clave del nuevo miembro

cd /DigIdCom/ca

openssl genrsa -out privateMember/$NAME_PATH.key.pem 2048
chmod 400 privateMember/$NAME_PATH.key.pem

