# Camunda Platform 7 Spring Boot Tutorial Lafayette
This project is used as part of a video tutorial in order to show how you can use various features of Camunda 7 in a spring boot application.
Be aware that this is specific to Camunda 7 and concepts described here are not compatible with Camunda Platform 8.

## Camunda 7.15 vs. 7.22
Camunda 7.22.0’s migration to Jakarta EE 9, which renames packages from javax.* to jakarta.*. You’re currently using Spring Boot 2.7.x, which is not fully compatible with Jakarta EE 9.

Starting with Camunda 7.20+, especially 7.21 and 7.22, there was a major platform shift:

🚨 Camunda moved to Jakarta EE 9+, which includes:
	•	javax.* → jakarta.* package renaming
	•	Dependency on Jakarta Servlet 5.0+
	•	Requires Java 17+
	•	Requires Spring Boot 3.0+

🔁 This shift broke compatibility with:
	•	Spring Boot 2.x
	•	Older servlet-based libraries using javax.servlet.*

So 7.22 will not work properly in your Spring Boot 2.7 + Java 11 stack unless you upgrade both.

## Dev, Prod

- Dev mode: mvn spring-boot:run -Dspring-boot.run.profiles=dev
- Prod mode: mvn spring-boot:run -Dspring-boot.run.profiles=prod

If deploying in Docker, use environment-specific configuration files with:
export SPRING_PROFILES_ACTIVE=prod
export ADMIN_PASSWORD=securepassword

![Video Tutorial Badge](https://img.shields.io/badge/Tutorial%20Reference%20Project-Tutorials%20for%20getting%20started%20with%20Camunda-%2338A3E1)
<img src="https://img.shields.io/badge/Camunda%20DevRel%20Project-Created%20by%20the%20Camunda%20Developer%20Relations%20team-0Ba7B9"> ![Compatible with: Camunda Platform 7](https://img.shields.io/badge/Compatible%20with-Camunda%20Platform%207-26d07c)

You'll find the tutorial videos by clicking the image below

[![Camunda Spring Boot Tutorial](http://img.youtube.com/vi/WCznCZxHZ9k/0.jpg)](https://www.youtube.com/watch?v=sgcSm7YneTs&list=PLJG25HlmvsOVssaiPmavxv3htN_dXS3BW&index=1)

## What is this all about?
When creating example projects I like to ensure that the examples I use are as close to real world use cases as possible and so in this example we'll be building a process in which we can help one of my favourite historical figures [Gilbert du Motier, Marquis de Lafayette](https://en.wikipedia.org/wiki/Gilbert_du_Motier,_Marquis_de_Lafayette) to do what he does best - get involved in revolutions! 

This is broken up into 4 parts and in the end we're looking a process that will help Lafayette with a more efficient way to ruin things for the French and British monarchy. 

![process](./src/main/resources/images/laffProcessDiagram.png)

## What you will need 
* [Java JDK 11](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html) so that you can run the Camunda Platform
* [Camunda Modeler](https://camunda.com/download/modeler/) for building and deploying BPMN Models
* An integrated development environment for Java like [IntelliJ IDEA](https://www.jetbrains.com/idea/download/) 

## What will you learn?
* How to setup a spring boot project with Camunda
* Understanding the components of the project
* How to create forms and link them to user tasks
* How to write java classes that can be run by Service Tasks
* How to configure an XOR gateway based on process data
* How to configure non-interrupting timer events
* How to trigger and catch BPMN errors thrown from Java Code


### Part One: Lafayette's Departure 
<span style="color:Orange">Using User tasks and Camunda Forms</span>.
![LafayetteV1](./src/main/resources/images/LafayetteV1.png)


### Part Two: Lafayette Crosses the Ocean 
<span style="color:Orange">Using Service Tasks, Java Classes and Gateways</span>.
![LafayetteV2](./src/main/resources/images/LafayetteV2.png)


## Part Three: Lafayette Writes Home
<span style="color:Orange">Using Timers and User Tasks</span>.
![LafayetteV3](./src/main/resources/images/LafayetteV3.png)

## Part Four: Disaster at Sea for Lafayette
<span style="color:Orange">Using Java to throw BPMN Error Events</span>.
![LafayetteV4](./src/main/resources/images/LafayetteV4.png)
