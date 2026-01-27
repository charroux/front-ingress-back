# Stage 1: Build
FROM gradle:8.5-jdk21 AS builder

WORKDIR /app

# Copie les fichiers Gradle
COPY build.gradle .
COPY settings.gradle .
COPY gradle ./gradle

# Copie le code source
COPY src ./src

# Construit l'application (Gradle est déjà disponible)
RUN gradle bootJar --no-daemon

# Stage 2: Runtime
FROM eclipse-temurin:21-jre

WORKDIR /app

# Copie le JAR depuis le stage de build
COPY --from=builder /app/build/libs/order-service-*.jar app.jar

EXPOSE 8080

# Lance l'application
ENTRYPOINT ["java", "-jar", "app.jar"]
