MEMBER=$1
EXEUSER_PATH=$2

echo 'SET foreign_key_checks = 0;\nDELETE from DigIdCom.miembro where ID='\'$MEMBER\''; \nDELETE from DigIdCom.gestor where ID='\'$MEMBER\''; \nDROP user '$MEMBER'@localhost; ' > deleteTEMP.sql

mysql -u $EXEUSER_PATH -p < deleteTEMP.sql

rm deleteTEMP.sql

rm /DigIdCom/ca/privateMember/$MEMBER.key.pem
