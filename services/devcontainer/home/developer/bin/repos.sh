#!/bin/bash
set -e

CONF_DIR="${1:-$HOME/workspace/.vscode}"
echo "using configuration in $CONF_DIR"

if [ ! -f "$CONF_DIR/environment.json" ]; then
    echo "Error: The file environment.json was not found in the $CONF_DIR folder!"
    exit 1
fi

credential() {
  local credential="$1"
  USERNAME=$(echo "$credential" | jq -r '.username')
  PASSWORD=$(echo "$credential" | jq -r '.password')
  DOMAIN=$(echo "$credential" | jq -r '.domain')

  # Wichtig: Keine Leerzeichen vor den Variablen und kein Freizeichen vor EOF!
  git credential-store erase <<EOF
protocol=https
host=${DOMAIN}
username=${USERNAME}
EOF

  git credential-store store <<EOF
protocol=https
host=${DOMAIN}
username=${USERNAME}
password=${PASSWORD}
EOF
}

repo() {
  local repository="$1"

  NAME=$(echo "$repository" | jq -r '.name')
  URL=$(echo "$repository" | jq -r '.url')
  SIGN=$(echo "$repository" | jq -r '.sign')
  SIGNKEY=$(echo "$repository" | jq -r '.signkey')
  USERNAME=$(echo "$repository" | jq -r '.username')
  EMAIL=$(echo "$repository" | jq -r '.email')
  
  mkdir -p ~/workspace

  cd ~/workspace || exit 1
  if [ ! -d "$NAME" ]; then
    echo "cloning $URL into $NAME"
    git clone "$URL" "$NAME"
  else
    echo "repo $NAME already cloned"
  fi

  echo "Updating git config..."
  cd ~/workspace/$NAME 2>/dev/null || cd "~/workspace/$NAME" || exit 1
  git config commit.gpgsign "$SIGN"
  git config user.signingkey "$SIGNKEY"
  git config user.name "$USERNAME"
  git config user.email "$EMAIL"
  echo "--- Fertig ---"
  echo 
}

jq -c '.gitcredentials[]' $CONF_DIR/environment.json | while read -r item; do
  credential "$item"
done

jq -c '.repositories[]' $CONF_DIR/environment.json | while read -r item; do
    repo "$item"
done