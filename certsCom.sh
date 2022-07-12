
COMMUNITY=$1
EXE_PATH=$2

echo 'SELECT serialNumber FROM emite WHERE serialNumber_int = (SELECT serialNumber_int FROM certifica WHERE nombreComunidad = '\'$COMMUNITY\'');' > consulTEMP.sql

mysql -u $EXE_PATH -p < consulTEMP.sql 

rm consulTEMP.sql
