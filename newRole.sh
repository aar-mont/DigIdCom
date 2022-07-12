USER_PATH=$1
PASS_PATH=$2
TYPE_PATH=$3
EXE_PATH=$4

#echo 'DROP user '$USER_PATH'@localhost;\nCREATE user '$USER_PATH'@localhost identified by '\'$PASS_PATH\'';' > creadorTEMPORAL.sql

if [ $TYPE_PATH = miembro ];
then
	echo 'USE DigIdCom;\nDELETE from DigIdCom.gestor where ID = '\'$USER_PATH\'';' > insertTEMPORAL.sql
	echo 'REVOKE ALL PRIVILEGES, GRANT OPTION from '\'$USER_PATH\''@'localhost'; \nGRANT SELECT on 'DigIdCom'.'miembro' to '\'$USER_PATH\''@localhost;\nGRANT SELECT on 'DigIdCom'.'gestor' to '\'$USER_PATH\''@localhost;\nGRANT SELECT on 'DigIdCom'.'comunidad' to '\'$USER_PATH\''@localhost;'> permisosTEMPORAL.sql

elif [ $TYPE_PATH = gestor ];
then
	echo 'USE DigIdCom;\nINSERT INTO DigIdCom.gestor(nombreApellidos, ID) VALUES ((SELECT nombreApellidos FROM DigIdCom.miembro where ID = '\'$USER_PATH\''), '\'$USER_PATH\'');' > insertTEMPORAL.sql
	echo 'REVOKE ALL PRIVILEGES, GRANT OPTION from '\'$USER_PATH\''@'localhost'; \nGRANT SELECT,INSERT,UPDATE,DELETE on 'DigIdCom'.'*' to '$USER_PATH'@localhost ;\nGRANT CREATE USER ON *.* to '$USER_PATH'@localhost WITH GRANT OPTION;'> permisosTEMPORAL.sql
	
else
	echo 'Rol no existente. Roles disponibles miembro y gestor'
fi

cat permisosTEMPORAL.sql insertTEMPORAL.sql > completeTEMP.sql

rm insertTEMPORAL.sql permisosTEMPORAL.sql

mysql -u $EXE_PATH -p < completeTEMP.sql

rm completeTEMP.sql
