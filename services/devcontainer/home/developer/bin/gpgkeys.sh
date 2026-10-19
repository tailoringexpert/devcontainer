
#!/bin/bash
set -e
export GPG_TTY=$(tty)

CONF_DIR="${1:-$HOME/workspace/.vscode}"
echo "using configuration in $CONF_DIR"

if [ ! -f "$CONF_DIR/environment.json" ]; then
    echo "Error: The file environment.json was not found in the $CONF_DIR folder!"
    exit 1
fi

restore() {
    local gpg="$1"

    local KEY_TEXT=$(echo "$gpg" | jq -r '.key')
    local PASSPHRASE=$(echo "$gpg" | jq -r '.passphrase')

    local TMP_KEY=""    
    TMP_KEY=$(mktemp)
    echo "$KEY_TEXT" > "$TMP_KEY"

    # 1. Schlüssel importieren (|| true verhindert den Abbruch durch set -e)
    local GPG_OUT=""
    GPG_OUT=$(gpg --batch --status-fd 1 --import "$TMP_KEY" 2>/dev/null || true)
    
    # 2. Fingerabdruck aus dem Import-Status auslesen
    local FINGERPRINT=""
    FINGERPRINT=$(echo "$GPG_OUT" | awk '/\[GNUPG:\] IMPORT_OK/ {print $4}')
    
    # 3. FALLBACK: Falls der Schlüssel schon existierte, nutzen wir --import-options show-only
    # Das ist bei privaten Schlüsseln deutlich stabiler als --show-keys
    if [ -z "$FINGERPRINT" ]; then
        FINGERPRINT=$(gpg --with-colons --import-options show-only --import "$TMP_KEY" 2>/dev/null | awk -F: '$1 == "fpr" {print $10; exit}' || true)
    fi

    rm -f "$TMP_KEY"

    # 4. Validierung des aktuellen Fingerabdrucks
    if [ -z "$FINGERPRINT" ]; then
        echo "❌ Fehler: Ein Schlüssel konnte nicht importiert werden."
        return 0 
    fi

    echo "Erfolgreich importiert. Aktueller Fingerabdruck: $FINGERPRINT"
    
    # 5. Vertrauen auf 'Ultimativ' setzen
    echo "$FINGERPRINT:6:" | gpg --import-ownertrust &>/dev/null || true
    echo "Vertrauen für diesen Schlüssel auf 'Ultimativ' gesetzt."
}

config()
{
    local gpg="$1"
    
    local EMAIL=$(echo "$gpg" | jq -r '.email')
    local PASSPHRASE=$(echo "$gpg" | jq -r '.passphrase')
  
    echo "test" | gpg --local-user "$EMAIL" --passphrase "$PASSPHRASE" --batch --yes --pinentry-mode loopback --clearsign
}

jq -c '.gpgkeys[]' $CONF_DIR/environment.json | while read -r item; do
    restore "$item"
    config "$item"
done