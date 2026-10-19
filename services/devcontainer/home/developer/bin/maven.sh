#!/bin/bash
set -e

CONF_DIR="${1:-$HOME/workspace/.vscode}"
echo "using configuration in $CONF_DIR"

CONF_FILE="$CONF_DIR/environment.json"
if [ ! -f "$CONF_FILE" ]; then
    echo "Error: The file environment.json was not found in the $CONF_DIR folder!"
    exit 1
fi


SERVER_ID=$(jq -r '.maven.server.id' $CONF_DIR/environment.json)
SERVER_USER=$(jq -r '.maven.server.user' $CONF_DIR/environment.json)
SERVER_TOKEN=$(jq -r '.maven.server.token' $CONF_DIR/environment.json)
SONAR_ACTIVATE=$(jq -r '.maven.sonar.activate' "$CONF_DIR/environment.json")
SONAR_URL=$(jq -r '.maven.sonar.url' "$CONF_DIR/environment.json")
SONAR_TOKEN=$(jq -r '.maven.sonar.token' "$CONF_DIR/environment.json")

cat << EOF > "$HOME/.m2/settings.xml"
<settings>
    <servers>
        <server>
            <id>${SERVER_ID}</id>
            <username>${SERVER_USER}</username>
            <password>${SERVER_TOKEN}</password>
        </server>
    </servers>

    <profiles>
        <profile>
            <id>sonar</id>
            <activation>
                <activeByDefault>${SONAR_ACTIVATE}</activeByDefault>
            </activation>
            <properties>
                <sonar.token>${SONAR_TOKEN}</sonar.token>
                <sonar.host.url>${SONAR_URL}</sonar.host.url>
            </properties>
        </profile>
        <profile>
            <id>demo</id>
            <activation>
                <activeByDefault>true</activeByDefault>
            </activation>
            <properties>
                <db>demo</db>
                <liquibase.username>tailoringexpert_demo</liquibase.username>
                <liquibase.password>test1234</liquibase.password>
                <liquibase.driver>org.mariadb.jdbc.Driver</liquibase.driver>
                <liquibase.url>jdbc:mariadb://devcontainer-db:3306/tailoringexpert_demo</liquibase.url>
            </properties>
        </profile>
        <profile>
            <id>sources</id>
            <activation>
                <activeByDefault>true</activeByDefault>
            </activation>
            <properties>
                <downloadSources>true</downloadSources>
                <downloadJavadocs>true</downloadJavadocs>
            </properties>
        </profile>        
    </profiles>
</settings>
EOF
