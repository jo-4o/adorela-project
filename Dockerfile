# Stage 1: Build
FROM docker.io/library/maven:3.9-eclipse-temurin-17-alpine AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Run
FROM docker.io/library/eclipse-temurin:17-jre-alpine
WORKDIR /app

# Cria diretório de uploads
RUN mkdir -p /app/uploads

# Copia JAR da etapa de build
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
