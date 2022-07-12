OWNER_PATH=$1 #identificador del miembro

cd ca

openssl genrsa -out privateMember/$OWNER_PATH.key.pem 2048
chmod 400 privateMember/$OWNER_PATH.key.pem




