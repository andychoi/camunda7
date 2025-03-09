FROM openjdk:11-jdk-slim

WORKDIR /app

COPY target/camunda-bpm-spring-boot-starter-webapp-1.0.jar /app/app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/app.jar"]