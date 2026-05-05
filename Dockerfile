# Stage 1: Build
FROM docker.io/library/maven:3.9-eclipse-temurin-17-alpine AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Run
FROM docker.io/library/eclipse-temurin:17-jre-alpine
WORKDIR /app

# Cria diretórios de uploads e certificados
RUN mkdir -p /app/uploads /app/certs

# Copia JAR da etapa de build
COPY --from=build /app/target/*.jar app.jar

# Copia o keystore TLS (PKCS12) gerado por ./generate-certs.sh
# Antes de buildar a imagem, execute na raiz do projeto:
#   chmod +x generate-certs.sh && ./generate-certs.sh
COPY certs/api-keystore.p12 /app/certs/api-keystore.p12

# Spring Boot encontra o keystore no caminho padrão configurado em application.properties
ENV SERVER_PORT=8443 \
    SERVER_SSL_ENABLED=true \
    SERVER_SSL_KEY_STORE=file:/app/certs/api-keystore.p12 \
    SERVER_SSL_KEY_STORE_TYPE=PKCS12 \
    SERVER_SSL_KEY_STORE_PASSWORD=adorela123 \
    SERVER_SSL_KEY_ALIAS=adorela-api

EXPOSE 8443

ENTRYPOINT ["java", "-jar", "app.jar"]
