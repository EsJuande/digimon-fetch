#!/usr/bin/env bash

DATA_DIR="$HOME/.local/share/digimonfetch"
CACHE_DIR="$HOME/.cache/digimonfetch"

DIGI_DB="$DATA_DIR/digimon.json"
IMAGE_DIR="$DATA_DIR/images"

PARTNER_FILE="$CACHE_DIR/partner.json"
STAGE_FILE="$CACHE_DIR/stage"

mkdir -p "$CACHE_DIR"

if [ ! -f "$DIGI_DB" ]; then
    echo "Digimon database not found."
    exit 1
fi


# --------------------------
# CLI args
# --------------------------

FORCE_EVOLVE=false

for arg in "$@"; do
    case "$arg" in
        --evolve)
            FORCE_EVOLVE=true
            echo "Se manda a evolucionar"
            ;;
    esac
done


# --------------------------
# uptime
# --------------------------

UPTIME_MIN=$(awk '{print int($1/60)}' /proc/uptime)

stage_from_uptime() {

    if [ "$UPTIME_MIN" -lt 30 ]; then
        echo 0
    elif [ "$UPTIME_MIN" -lt 120 ]; then
        echo 1
    elif [ "$UPTIME_MIN" -lt 360 ]; then
        echo 2
    elif [ "$UPTIME_MIN" -lt 720 ]; then
        echo 3
    else
        echo 4
    fi
}

CURRENT_STAGE=$(stage_from_uptime)


# --------------------------
# create/reset partner
# --------------------------

create_partner() {
    echo "Seleccionando un Digimon inicial (Child)..."

    # Traemos todos los Child/Rookie del API
    CHILD_LIST=$(curl -s "https://digi-api.com/api/v1/digimon?level=child&pageSize=500" | jq '.content')

    COUNT=$(echo "$CHILD_LIST" | jq length)
    INDEX=$((RANDOM % COUNT))

    # Tomamos el ID del Digimon elegido
    ID=$(echo "$CHILD_LIST" | jq -r ".[$INDEX].id")

    # HIT al API para traer la info completa del Digimon
    curl -s "https://digi-api.com/api/v1/digimon/$ID" > "$PARTNER_FILE"

    # Guardamos la etapa actual
    echo "$CURRENT_STAGE" > "$STAGE_FILE"

    echo "Tu partner inicial es $(jq -r '.name' "$PARTNER_FILE")!"
}

# Si no hay partner, crear uno
if [ ! -f "$PARTNER_FILE" ]; then
    create_partner
fi

# CLI flag --reset ahora también crea uno nuevo
case "$1" in
    --reset)
        rm -f "$PARTNER_FILE"
        rm -f "$STAGE_FILE"
        create_partner
        exit 0
        ;;
esac


# --------------------------
# evolution logic
# --------------------------

evolve_partner() {
    NEXT_COUNT=$(jq '.nextEvolutions | length' "$PARTNER_FILE")

    if [ "$NEXT_COUNT" -eq 0 ]; then
        echo "No next evolutions available."
        return
    fi

    INDEX=$((RANDOM % NEXT_COUNT))

    NEXT_URL=$(jq -r ".nextEvolutions[$INDEX].url" "$PARTNER_FILE")

    if [ -z "$NEXT_URL" ] || [ "$NEXT_URL" = "null" ]; then
        echo "Next evolution URL missing."
        return
    fi

    # Llamada al API para la evolución
    curl -s "$NEXT_URL" > "$PARTNER_FILE"

    echo "Evolved into $(jq -r '.name' "$PARTNER_FILE")!"
}


# --------------------------
# evolution by uptime
# --------------------------

if [ -f "$STAGE_FILE" ]; then
    LAST_STAGE=$(cat "$STAGE_FILE")
else
    LAST_STAGE=0
fi


if [ "$FORCE_EVOLVE" = true ]; then

    evolve_partner

elif [ "$CURRENT_STAGE" -gt "$LAST_STAGE" ]; then

    evolve_partner
    echo "$CURRENT_STAGE" > "$STAGE_FILE"

fi


# --------------------------
# load partner
# --------------------------

NAME=$(jq -r '.name' "$PARTNER_FILE")
LEVEL=$(jq -r '.levels[0].level // "Unknown"' "$PARTNER_FILE")

SAFE_NAME=$(echo "$NAME" | tr ' ' '_' | tr '[:upper:]' '[:lower:]')

IMAGE_FILE="$IMAGE_DIR/${SAFE_NAME}.png"


# --------------------------
# CLI flags
# --------------------------

case "$1" in

--name)
echo "$NAME"
exit
;;

--level)
echo "$LEVEL"
exit
;;

--image)
echo "$IMAGE_FILE"
exit
;;

--reset)
rm -f "$PARTNER_FILE"
rm -f "$STAGE_FILE"
echo "Partner reset."
exit
;;

--evolve)
exit
;;

esac


# --------------------------
# Crear módulo temporal para Fastfetch
# --------------------------

TMP_MODULE=$(mktemp)

cat > "$TMP_MODULE" <<EOF
{
  "name": "Partner Digimon",
  "type": "custom",
  "content": [
    {
      "type": "text",
      "value": "󰐗 $NAME  |  󰆧 $LEVEL"
    },
    {
      "type": "custom",
      "value": "$IMAGE_FILE"
    }
  ]
}
EOF


# --------------------------
# Output: ASCII + módulos
# --------------------------

# Preparamos el texto de los módulos del Digimon
PARTNER_MODULES=$(printf "󰐗 Partner Digimon : %s\n󰆧 Level           : %s\n" "$NAME" "$LEVEL")

echo
echo "󰐗 Partner Digimon : $NAME"
echo "󰆧 Level           : $LEVEL"
echo


if command -v fastfetch >/dev/null 2>&1; then

    fastfetch \
        --logo none \
        --chafa "$IMAGE_FILE" \
        --logo-width 40

fi