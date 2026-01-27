# Stage 1: Build
FROM maven:3.9-eclipse-temurin-21 AS builder

WORKDIR /app

# Copie pom.xml et télécharge les dépendances
COPY pom.xml .
RUN mvn dependency:go-offline

# Copie le code source
COPY src ./src

# Construit l'application
RUN mvn clean package -DskipTests

# Stage 2: Runtime
FROM eclipse-temurin:21-jre

WORKDIR /app

# Copie le JAR depuis le stage de build
COPY --from=builder /app/target/order-service-*.jar app.jar

EXPOSE 8080

# Lance l'application
ENTRYPOINT ["java", "-jar", "app.jar"]
