#!/bin/sh
# command line params
# $1 -> repository to deploy name (mandatory)
# $2 -> name of profile to use (optional)

REPOSITORY_ID="$1"
PROFILE="$2"

PLATFORM_PATH=$HOME/workspace/platform
POM_FILE="$PLATFORM_PATH/pom.xml"
if [ ! -f "$POM_FILE" ]; then
    echo "$POM_FILE does not exists" >&2
    exit 1
fi

# determine version
VERSION=$(grep -m 1 '<version>' "$POM_FILE" | sed -e 's/^[ \t]*//' -e 's/<version>//' -e 's/<\/version>//')
if [ -z "$VERSION" ]; then
    echo "No version found in $POM_FILE." >&2
    exit 1
fi

# determine repo property name
if echo "$VERSION" | grep -q "SNAPSHOT"; then
    PROPERTY_NAME="tailoringexpert-snapshots.repository"
else 
    PROPERTY_NAME="tailoringexpert-releases.repository"  
fi

# use user settings
SETTINGS_FILE="/home/developer/.m2/settings.xml"
if [ ! -f "$SETTINGS_FILE" ]; then
    echo "$SETTINGS_FILE not found" >&2
    exit 1
fi

# use profile or default?
if [ -z "$PROFILE" ]; then
    echo "No Profil given -> activeByDefault"
    SEARCH_PATTERN="<activeByDefault>true</activeByDefault>"
else
    echo "Using profil '$PROFILE'"
    SEARCH_PATTERN="<id>${PROFILE}</id>"
fi

# extract url
REPO_URL=$(awk -v pattern="$SEARCH_PATTERN" -v prop="$PROPERTY_NAME" '
    $0 ~ pattern { in_profile=1; buffer="" }
    in_profile && $0 ~ "</profile>" { in_profile=0 }
    in_profile && $0 ~ "<"prop">" { inside_tag=1 }
    inside_tag {
        buffer = buffer " " $0
        if ($0 ~ "</"prop">") {
            inside_tag=0
            print buffer
            exit
        }
    }
' "$SETTINGS_FILE" | sed -e "s/.*<$PROPERTY_NAME>//" -e "s/<\/$PROPERTY_NAME>.*//" | xargs)


echo "deploy-file tailoringexpert-bootapp-$VERSION-exec.jar -> $REPO_URL"
cd $PLATFORM_PATH
mvn deploy:deploy-file \
  -Dfile=tailoringexpert-bootapp/target/tailoringexpert-bootapp-$VERSION-exec.jar \
  -DpomFile=tailoringexpert-bootapp/pom.xml \
  -Dclassifier=exec \
  -DrepositoryId=$REPOSITORY_ID \
  -Durl=$REPO_URL 


