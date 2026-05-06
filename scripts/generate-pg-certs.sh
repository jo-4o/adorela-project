#!/bin/bash

# Cria o diretório de certificados se não existir
mkdir -p certs

echo "Gerando certificados TLS para o PostgreSQL..."

openssl req -new -x509 -days 365 -nodes -text \
  -out certs/postgres-server.crt \
  -keyout certs/postgres-server.key \
  -subj "/CN=postgres"

# Ajusta as permissões do arquivo de chave privada (necessário para o PostgreSQL)
chmod 600 certs/postgres-server.key

echo "Certificados gerados em ./certs/postgres-server.crt e ./certs/postgres-server.key"
