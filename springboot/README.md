🚀 Spring Boot with Camunda 7

https://docs.camunda.org/manual/latest/user-guide/spring-boot-integration/
https://github.com/camunda/camunda-bpm-platform/tree/master/spring-boot-starter

webapp: https://github.com/camunda/camunda-bpm-examples/blob/7.18/spring-boot-starter/example-webapp/README.md
auto-deploy: https://github.com/camunda/camunda-bpm-examples/tree/7.18/spring-boot-starter/example-autodeployment

By default the application path is /camunda, so without any further configuration you can access the Webapps under http://localhost:8080/camunda/app/.

- 7.15 - 7.19 Java 8 -> recommend Java 11
- 7.20+ - Java 11 -> recommend Java 17


Since you want Camunda 7 running with Spring Boot instead of Tomcat, we need to:
	1.	Use Camunda 7 Spring Boot Starter instead of the standalone Tomcat distribution.
	2.	Modify the Dockerfile to run a Spring Boot JAR.
	3.	Update docker-compose.yml to work with PostgreSQL.
	4.	Ensure PostgreSQL JDBC driver is correctly set up.

⸻

✅ 1️⃣ Create a New Spring Boot Project for Camunda 7

Use Spring Initializr to generate a Spring Boot project with:
	•	Spring Boot version: 2.7.x (compatible with Camunda 7)
	•	Dependencies:
	•	camunda-bpm-spring-boot-starter
	•	spring-boot-starter-web
	•	spring-boot-starter-data-jpa
	•	postgresql
	•	flywaydb (for database migrations)

You can generate it manually or via:

curl https://start.spring.io/starter.zip \
  -d dependencies=camunda-bpm-spring-boot-starter,spring-boot-starter-web,postgresql,flywaydb \
  -d name=CamundaSpringBoot \
  -d type=maven-project \
  -o camunda-spring-boot.zip

Then extract the zip:

unzip camunda-spring-boot.zip -d camunda-spring-boot
cd camunda-spring-boot


⸻
Your project should have this structure:

camunda-spring-boot/
│── src/
│   ├── main/
│   │   ├── java/com/example/
│   │   │   ├── CamundaApplication.java  # ✅ Main Spring Boot Class
│   │   │   ├── MyCamundaConfig.java  # ✅ Camunda Configuration (Optional)
│   │   ├── resources/
│   │   │   ├── application.yml  # ✅ Spring Boot Config
│── pom.xml
│── Dockerfile
│── docker-compose.yml

If your CamundaApplication.java is in a different package, move it to com.example or update pom.xml to reflect the correct package.
⸻


⸻

✅ 2️⃣ Update application.yml for PostgreSQL

Replace src/main/resources/application.yml with:

server:
  port: 8080

spring:
  datasource:
    url: jdbc:postgresql://postgres:5432/camunda
    username: camunda
    password: camunda_password
    driver-class-name: org.postgresql.Driver
  jpa:
    database-platform: org.hibernate.dialect.PostgreSQLDialect
    hibernate:
      ddl-auto: update
  flyway:
    enabled: true

camunda:
  bpm:
    admin-user:
      id: demo
      password: demo
    database:
      schema-update: true
    webapp:
      index-redirect-enabled: true
    job-execution:
      enabled: true

✔ This ensures Camunda will connect to PostgreSQL using the camunda database.

⸻

✅ 3️⃣ Modify Dockerfile for Spring Boot

Replace Dockerfile with:

# Use an OpenJDK base image
FROM openjdk:17-jdk-slim

# Set environment variables
ENV SPRING_PROFILES_ACTIVE=prod

# Set working directory inside the container
WORKDIR /app

# Copy the built Spring Boot application JAR
COPY target/camunda-spring-boot.jar /app/camunda-spring-boot.jar

# Expose application ports
EXPOSE 8080

# Run the Spring Boot application
ENTRYPOINT ["java", "-jar", "/app/camunda-spring-boot.jar"]

✔ This will run the Camunda Spring Boot app without Tomcat.

⸻

✅ 4️⃣ Update docker-compose.yml

Replace docker-compose.yml with:

version: "3.8"

services:
  postgres:
    image: postgres:15
    container_name: camunda_postgres
    restart: always
    environment:
      POSTGRES_DB: camunda
      POSTGRES_USER: camunda
      POSTGRES_PASSWORD: camunda_password
      POSTGRES_INITDB_ARGS: "--auth=md5"
    volumes:
      - pg_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  camunda:
    build: .
    container_name: camunda_springboot
    restart: always
    depends_on:
      - postgres
    environment:
      SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/camunda
      SPRING_DATASOURCE_USERNAME: camunda
      SPRING_DATASOURCE_PASSWORD: camunda_password
      SPRING_JPA_DATABASE_PLATFORM: org.hibernate.dialect.PostgreSQLDialect
    ports:
      - "8080:8080"

volumes:
  pg_data:

✔ This ensures Camunda connects to PostgreSQL and runs the Spring Boot app.

⸻

✅ 5️⃣ Build & Run

1️⃣ Build the Spring Boot JAR

Run inside the project:

mvn clean package

The JAR will be created at:

target/camunda-spring-boot.jar

2️⃣ Build and Start Docker Containers

docker-compose up -d --build

3️⃣ Verify Running Containers

docker ps

Expected output:

CONTAINER ID   IMAGE                COMMAND                  STATUS          PORTS                    NAMES
abc123         camunda_springboot    "java -jar /app/camu…"   Up 10 seconds   0.0.0.0:8080->8080/tcp   camunda_springboot
def456         postgres:15           "docker-entrypoint.s…"   Up 10 seconds   0.0.0.0:5432->5432/tcp   camunda_postgres



⸻

✅ 6️⃣ Verify Camunda is Running

1️⃣ Open Camunda Web App

Visit:

http://localhost:8080

Login with:
	•	Username: demo
	•	Password: demo

2️⃣ Check Logs

docker-compose logs -f camunda

Expected output:

INFO  Camunda Webapp available at http://localhost:8080
INFO  Starting Camunda Spring Boot
INFO  Connected to PostgreSQL



⸻

🎯 Summary

✅ Replaced Tomcat-based Camunda with Spring Boot
✅ Configured PostgreSQL database in application.yml
✅ Updated Dockerfile to run the Spring Boot JAR
✅ Updated docker-compose.yml for database integration
🚀 Now Camunda 7 runs as a Spring Boot microservice with PostgreSQL! 🎯