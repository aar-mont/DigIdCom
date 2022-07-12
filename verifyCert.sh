USER=$1
COMMUNITY=$2

openssl verify -CAfile /DigIdCom/ca/intermediate$COMMUNITY/certs/chain.cert.pem /DigIdCom/ca/intermediate$COMMUNITY/certs/$USER.cert.pem 
