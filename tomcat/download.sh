#!/bin/sh -ex

# Define parameters for Camunda Community Edition
echo "Downloading Camunda ${VERSION} Community Edition for ${DISTRO}"
ARTIFACT="camunda-bpm-${DISTRO}"
ARTIFACT_VERSION="${VERSION}"

# Corrected Camunda Repository URL
CAMUNDA_REPO_URL="https://artifacts.camunda.com/public/org/camunda/bpm/${DISTRO}/${ARTIFACT}/${ARTIFACT_VERSION}"

# File format (Camunda distributes both .tar.gz and .zip)
FILE_TAR="${ARTIFACT}-${ARTIFACT_VERSION}.tar.gz"
FILE_ZIP="${ARTIFACT}-${ARTIFACT_VERSION}.zip"

# Ensure /camunda directory exists
mkdir -p /camunda

# Try downloading `.tar.gz` first, fallback to `.zip` if necessary
echo "Attempting to download ${FILE_TAR}..."
if wget -q --show-progress --progress=bar:force:noscroll -O "/tmp/${FILE_TAR}" "${CAMUNDA_REPO_URL}/${FILE_TAR}"; then
    echo "Successfully downloaded ${FILE_TAR}"
    FILE_DOWNLOADED="/tmp/${FILE_TAR}"
elif wget -q --show-progress --progress=bar:force:noscroll -O "/tmp/${FILE_ZIP}" "${CAMUNDA_REPO_URL}/${FILE_ZIP}"; then
    echo "Successfully downloaded ${FILE_ZIP}"
    FILE_DOWNLOADED="/tmp/${FILE_ZIP}"
else
    echo "Error: Unable to download Camunda BPM from ${CAMUNDA_REPO_URL}."
    exit 1
fi

# Extract the downloaded file
if [ "${FILE_DOWNLOADED##*.}" = "gz" ]; then
    echo "Extracting ${FILE_TAR}..."
    tar xzf "/tmp/${FILE_TAR}" -C /camunda 
elif [ "${FILE_DOWNLOADED##*.}" = "zip" ]; then
    echo "Extracting ${FILE_ZIP}..."
    unzip -q "${FILE_DOWNLOADED}" -d /camunda
else
    echo "Error: No valid Camunda archive found!"
    exit 1
fi

# Copy the appropriate startup script
cp "/tmp/camunda-${DISTRO}.sh" /camunda/camunda.sh

# Ensure Maven local repository directory exists
mkdir -p /root/.m2/repository

# Download PostgreSQL JDBC Driver
POSTGRESQL_VERSION=42.7.4  # Ensure latest version

echo "Downloading PostgreSQL JDBC Driver..."
wget -q -O /tmp/postgresql-${POSTGRESQL_VERSION}.jar \
    https://repo1.maven.org/maven2/org/postgresql/postgresql/${POSTGRESQL_VERSION}/postgresql-${POSTGRESQL_VERSION}.jar

# Verify if the file was successfully downloaded
if [ ! -f "/tmp/postgresql-${POSTGRESQL_VERSION}.jar" ]; then
    echo "Error: PostgreSQL JDBC Driver download failed!"
    exit 1
fi

echo "Successfully downloaded PostgreSQL JDBC Driver."

# Ensure Tomcat's lib directory exists
TOMCAT_LIB_DIR="/camunda/server/apache-tomcat-9.0.43/lib"
mkdir -p "${TOMCAT_LIB_DIR}"

# Move the PostgreSQL driver to Tomcat's lib directory
echo "Placing PostgreSQL JDBC Driver in ${TOMCAT_LIB_DIR}..."
cp /tmp/postgresql-${POSTGRESQL_VERSION}.jar "${TOMCAT_LIB_DIR}/"

# Verify if the file was successfully copied
if [ -f "${TOMCAT_LIB_DIR}/postgresql-${POSTGRESQL_VERSION}.jar" ]; then
    echo "PostgreSQL JDBC Driver successfully placed in Tomcat's lib folder."
else
    echo "Error: PostgreSQL JDBC Driver copy to ${TOMCAT_LIB_DIR} failed!"
    exit 1
fi

# Ensure necessary directories exist before copying files
mkdir -p /camunda/lib /camunda/bin /camunda/configuration/userlib

# Move database drivers to the appropriate directory based on Camunda distribution
case ${DISTRO} in
    wildfly*)
        cat <<-EOF > /tmp/batch.cli
batch
embed-server --std-out=echo

module add --name=org.postgresql.postgresql --slot=main --resources=/tmp/postgresql-${POSTGRESQL_VERSION}.jar --dependencies=javax.api,javax.transaction.api
/subsystem=datasources/jdbc-driver=postgresql:add(driver-name="postgresql",driver-module-name="org.postgresql.postgresql",driver-xa-datasource-class-name=org.postgresql.xa.PGXADataSource)

run-batch
EOF
        /camunda/bin/jboss-cli.sh --file=/tmp/batch.cli
        rm -rf /camunda/standalone/configuration/standalone_xml_history/current/*
        ;;
    run*)
        cp /tmp/postgresql-${POSTGRESQL_VERSION}.jar /camunda/configuration/userlib
        ;;
    tomcat*)
        cp /tmp/postgresql-${POSTGRESQL_VERSION}.jar /camunda/lib
        
        # Ensure /camunda/bin exists before modifying setenv.sh
        if [ -d "/camunda/bin" ]; then
            echo "" > /camunda/bin/setenv.sh
        else
            echo "Warning: /camunda/bin does not exist, skipping setenv.sh modification"
        fi
        ;;
esac

# Download Prometheus JMX Exporter
mvn dependency:copy -B \
    -Dartifact="io.prometheus.jmx:jmx_prometheus_javaagent:${JMX_PROMETHEUS_VERSION}:jar" \
    -DoutputDirectory=/tmp/

mkdir -p /camunda/javaagent
cp /tmp/jmx_prometheus_javaagent-${JMX_PROMETHEUS_VERSION}.jar /camunda/javaagent/jmx_prometheus_javaagent.jar