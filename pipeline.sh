#!/bin/bash
 
docker build .                                \
    -t camunda/camunda-bpm-platform:tomcat \
    --build-arg DISTRO=tomcat              