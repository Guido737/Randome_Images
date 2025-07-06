#!/bin/bash
set -e

IMAGES_DIR="images"
LOG_FILE="sent.log"
BOT_TOKEN="${BOT_TOKEN}"
CHAT_ID="${CHAT_ID}"

touch "$LOG_FILE"

all_images=($(ls "$IMAGES_DIR"))
sent_images=($(cat "$LOG_FILE"))

unsent_images=()
for img in "${all_images[@]}"; do
    if ! grep -qx "$img" "$LOG_FILE"; then
        unsent_images+=("$img")
    fi
done

if [ ${#unsent_images[@]} -eq 0 ]; then
    echo "All images has been sended. Log Restart."
    > "$LOG_FILE"
    unsent_images=("${all_images[@]}")
fi

RANDOM_IMAGE="${unsent_images[$RANDOM % ${#unsent_images[@]}]}"
echo "Sending: $RANDOM_IMAGE"

curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendPhoto" \
    -F chat_id="${CHAT_ID}" \
    -F photo=@"$IMAGES_DIR/$RANDOM_IMAGE"

echo "$RANDOM_IMAGE" >> "$LOG_FILE"
