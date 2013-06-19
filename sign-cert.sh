#!/bin/sh
# Sign a certificate request

# ./sign-cert.sh my_common_name remote_client_common_name [csr_file]

if [ ! -z "$1" ]; then
  MY_CN=$1
else
  exit 666
fi
if [ ! -z "$2" ]; then
  REMOTE_CN=$2
else
  exit 666
fi
if [ ! -z "$3" ]; then
  CSR_FILE=$3
else
  CSR_FILE="../cert-reqs/${GPLUS_ID}.csr"
fi

CA_CN="ca_$MY_CN"
CNF_FILE="../openssl.cnf"

cd keys

# Verify the CN
CSR_CN= openssl req -noout -subject -in "$CSR_FILE"
if [ ! $CSR_CN = "/CN=$REMOTE_CN/name=$REMOTE_CN" ]; then
  exit 333
fi


# Sign the certificate
openssl ca -batch -keyfile "$CA_CN.key" -cert "$CA_CN.crt" -in "$CSR_FILE" -days 1900 \
  -out "../cert-reqs/${MY_CN}_$REMOTE.crt" -config "$CNF_FILE"

