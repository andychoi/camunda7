# 1. Build Stage
FROM maven:3.9.6-eclipse-temurin-17 AS builder
WORKDIR /app

# Copy and build the project
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn package -DskipTests

# 2. Run Stage
FROM eclipse-temurin:17-jre AS runtime
WORKDIR /app

# Copy the built JAR from the builder stage
COPY --from=builder /app/target/camunda7*.jar camunda7.jar

# Expose the port used by the application
EXPOSE 8080

# Set default profile to production, override if needed
ENV SPRING_PROFILES_ACTIVE=prod

# ✅ Corrected: Use `camunda-db` instead of `localhost`
ENV DB_URL=jdbc:postgresql://camunda-db:5432/camunda
ENV DB_USERNAME=postgres
ENV DB_PASSWORD=postgres

# Run the application
ENTRYPOINT ["java", "-jar", "camunda7.jar"]