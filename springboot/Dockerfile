FROM openjdk:11-jdk-slim

WORKDIR /app

COPY target/springboot-customized-webapp-example.jar /app/app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/app.jar"]