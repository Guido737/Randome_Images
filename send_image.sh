#!/bin/bash
set -e

IMAGES_DIR="images"
LOG_FILE="sent.log"
BOT_TOKEN="${BOT_TOKEN}"
CHAT_ID="${CHAT_ID}"

if [[ -z "$BOT_TOKEN" || -z "$CHAT_ID" ]]; then
  echo "ERROR: BOT_TOKEN or CHAT_ID is not set!" >&2
  exit 1
fi

if [ ! -d "$IMAGES_DIR" ]; then
  echo "Directory $IMAGES_DIR does not exist!" >&2
  exit 1
fi

if [ ! -f "$LOG_FILE" ]; then
  touch "$LOG_FILE"
fi

mapfile -t all_images < <(find "$IMAGES_DIR" -maxdepth 1 -type f -printf '%f\n')
mapfile -t sent_images < "$LOG_FILE"

unsent_images=()
for img in "${all_images[@]}"; do
  if ! grep -qxF "$img" "$LOG_FILE"; then
    unsent_images+=("$img")
  fi
done

if [ ${#unsent_images[@]} -eq 0 ]; then
  echo "All images have been sent. Restarting log."
  > "$LOG_FILE"
  unsent_images=("${all_images[@]}")
fi

RANDOM_IMAGE="${unsent_images[$RANDOM % ${#unsent_images[@]}]}"
echo "Sending: $RANDOM_IMAGE"

response=$(curl -s -w "%{http_code}" -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendPhoto" \
  -F chat_id="${CHAT_ID}" \
  -F photo=@"$IMAGES_DIR/$RANDOM_IMAGE")


http_code="${response: -3}"
if [ "$http_code" != "200" ]; then
  echo "Failed to send photo. Response: $response" >&2
  exit 1
fi

echo "$RANDOM_IMAGE" >> "$LOG_FILE"
