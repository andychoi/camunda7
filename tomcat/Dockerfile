FROM alpine:3.12 AS builder

ARG VERSION=7.15.0
ARG DISTRO=tomcat
ARG SNAPSHOT=false

ARG EE=false
ARG USER
ARG PASSWORD

ARG JMX_PROMETHEUS_VERSION=0.20.0

RUN apk add --no-cache \
        bash \
        ca-certificates \
        maven \
        tar \
        wget \
        xmlstarlet

COPY settings.xml download.sh camunda-run.sh camunda-tomcat.sh /tmp/

RUN /tmp/download.sh


##### FINAL IMAGE #####

FROM alpine:3.12

ARG VERSION=7.15.0

ENV CAMUNDA_VERSION=${VERSION}
ENV DB_DRIVER=
ENV DB_URL=
ENV DB_USERNAME=
ENV DB_PASSWORD=
ENV DB_CONN_MAXACTIVE=20
ENV DB_CONN_MINIDLE=5
ENV DB_CONN_MAXIDLE=20
ENV DB_VALIDATE_ON_BORROW=false
ENV DB_VALIDATION_QUERY="SELECT 1"
ENV SKIP_DB_CONFIG=
ENV WAIT_FOR=
ENV WAIT_FOR_TIMEOUT=30
ENV TZ=UTC
ENV DEBUG=false
ENV JAVA_OPTS="-Xmx768m -XX:MaxMetaspaceSize=256m"
ENV JMX_PROMETHEUS=false
ENV JMX_PROMETHEUS_CONF=/camunda/javaagent/prometheus-jmx.yml
ENV JMX_PROMETHEUS_PORT=9404

EXPOSE 8080 8000 9404

RUN apk add --no-cache \
        bash \
        ca-certificates \
        curl \
        openjdk11-jre-headless \
        tzdata \
        tini \
        xmlstarlet \
    && curl -o /usr/local/bin/wait-for-it.sh \
      "https://raw.githubusercontent.com/vishnubob/wait-for-it/a454892f3c2ebbc22bd15e446415b8fcb7c1cfa4/wait-for-it.sh" \
    && chmod +x /usr/local/bin/wait-for-it.sh

RUN addgroup -g 1000 -S camunda && \
    adduser -u 1000 -S camunda -G camunda -h /camunda -s /bin/bash -D camunda
WORKDIR /camunda
USER camunda

# Copy extracted Camunda files
COPY --chown=camunda:camunda --from=builder /camunda .

# Overwrite Camunda's default startup script with our custom script
COPY --chown=camunda:camunda camunda-tomcat.sh /camunda/
RUN chmod +x /camunda/camunda-tomcat.sh

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/camunda/camunda-tomcat.sh"]