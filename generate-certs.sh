#!/bin/bash
# =================================================================
# Script de geração de certificados TLS self-signed para o Adorela
# Execute uma vez antes de subir os containers:
#   chmod +x generate-certs.sh && ./generate-certs.sh
# =================================================================

set -e

CERT_DIR="./certs"
mkdir -p "$CERT_DIR"

echo "==> Gerando certificado self-signed para a API (Spring Boot / Tomcat)..."

# Gera chave privada + certificado X.509 (válido por 365 dias)
openssl req -x509 -newkey rsa:4096 -sha256 -days 365 -nodes \
  -keyout "${CERT_DIR}/api-key.pem" \
  -out    "${CERT_DIR}/api-cert.pem" \
  -subj   "/CN=e-instancia.net/O=Adorela/C=BR" \
  -addext "subjectAltName=DNS:localhost,DNS:e-instancia.net,IP:127.0.0.1"

echo "==> Convertendo para formato PKCS12 (necessário para o Spring Boot)..."
openssl pkcs12 -export \
  -in    "${CERT_DIR}/api-cert.pem" \
  -inkey "${CERT_DIR}/api-key.pem" \
  -out   "${CERT_DIR}/api-keystore.p12" \
  -name  adorela-api \
  -passout pass:adorela123

echo "==> Gerando certificado self-signed para o PostgreSQL..."
openssl req -x509 -newkey rsa:4096 -sha256 -days 365 -nodes \
  -keyout "${CERT_DIR}/pg-key.pem" \
  -out    "${CERT_DIR}/pg-cert.pem" \
  -subj   "/CN=adorela-db/O=Adorela/C=BR"

# PostgreSQL exige permissões específicas para os arquivos de chave
chmod 600 "${CERT_DIR}/pg-key.pem"
chmod 644 "${CERT_DIR}/pg-cert.pem"

echo ""
echo "==> Certificados gerados com sucesso em: ${CERT_DIR}/"
echo ""
echo "Arquivos:"
ls -la "${CERT_DIR}/"
echo ""
echo "IMPORTANTE: Adicione 'certs/' ao .gitignore para não versionar os certificados!"
