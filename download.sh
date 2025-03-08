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
    tar xzf "${FILE_DOWNLOADED}" -C /camunda
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

# Download and register database drivers (MySQL & PostgreSQL) using Maven
mvn dependency:get -B --global-settings /tmp/settings.xml \
    -DremoteRepositories="camunda-nexus::::https://artifacts.camunda.com/public" \
    -DgroupId="org.camunda.bpm" -DartifactId="camunda-database-settings" \
    -Dversion="${ARTIFACT_VERSION}" -Dpackaging="pom" -Dtransitive=false \
    -Dmaven.repo.local=/root/.m2  # Explicitly set Maven local repository

# Find the downloaded database settings POM file
cambpmdbsettings_pom_file=$(find /root/.m2 -name "camunda-database-settings-${ARTIFACT_VERSION}.pom" -print | head -n 1)

# Check if the POM file was found
if [ -z "$cambpmdbsettings_pom_file" ]; then
    echo "Error: Database settings POM file not found!"
    exit 1
fi

# Extract MySQL & PostgreSQL versions
MYSQL_VERSION=$(xmlstarlet sel -t -v "//_:version.mysql" "$cambpmdbsettings_pom_file" || echo "8.0.33")
POSTGRESQL_VERSION=$(xmlstarlet sel -t -v "//_:version.postgresql" "$cambpmdbsettings_pom_file" || echo "42.5.4")

echo "MySQL version: ${MYSQL_VERSION}"
echo "PostgreSQL version: ${POSTGRESQL_VERSION}"

# Download the correct MySQL & PostgreSQL drivers
mvn dependency:copy -B -Dartifact="mysql:mysql-connector-java:${MYSQL_VERSION}:jar" -DoutputDirectory=/tmp/
mvn dependency:copy -B -Dartifact="org.postgresql:postgresql:${POSTGRESQL_VERSION}:jar" -DoutputDirectory=/tmp/

# Ensure necessary directories exist before copying files
mkdir -p /camunda/lib /camunda/bin /camunda/configuration/userlib

# Move database drivers to the appropriate directory
case ${DISTRO} in
    wildfly*)
        cat <<-EOF > /tmp/batch.cli
batch
embed-server --std-out=echo

module add --name=mysql.mysql-connector-java --slot=main --resources=/tmp/mysql-connector-java-${MYSQL_VERSION}.jar --dependencies=javax.api,javax.transaction.api
/subsystem=datasources/jdbc-driver=mysql:add(driver-name="mysql",driver-module-name="mysql.mysql-connector-java",driver-xa-datasource-class-name=com.mysql.cj.jdbc.MysqlXADataSource)

module add --name=org.postgresql.postgresql --slot=main --resources=/tmp/postgresql-${POSTGRESQL_VERSION}.jar --dependencies=javax.api,javax.transaction.api
/subsystem=datasources/jdbc-driver=postgresql:add(driver-name="postgresql",driver-module-name="org.postgresql.postgresql",driver-xa-datasource-class-name=org.postgresql.xa.PGXADataSource)

run-batch
EOF
        /camunda/bin/jboss-cli.sh --file=/tmp/batch.cli
        rm -rf /camunda/standalone/configuration/standalone_xml_history/current/*
        ;;
    run*)
        cp /tmp/mysql-connector-java-${MYSQL_VERSION}.jar /camunda/configuration/userlib
        cp /tmp/postgresql-${POSTGRESQL_VERSION}.jar /camunda/configuration/userlib
        ;;
    tomcat*)
        cp /tmp/mysql-connector-java-${MYSQL_VERSION}.jar /camunda/lib
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