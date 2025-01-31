#!/bin/bash

# Function to recursively unzip files
recursive_unzip() {
  local dir="$1"

  # Loop through all files and directories in the current directory
  for item in "$dir"/*; do
    if [ -d "$item" ]; then
      # If item is a directory, call the function recursively
      recursive_unzip "$item"
    elif [ -f "$item" ] && [[ "$item" == *.zip ]]; then
      # If item is a zip file, unzip it
      echo "Unzipping: $item"
      unzip -o "$item" -d "${item%.zip}" && rm "$item"
    elif [ -f "$item" ] && [[ "$item" == *.gz ]]; then
      # If item is a gzip file, gunzip it
      echo "gunzipping: $item"
      gunzip "${item%.gz}"
    fi
  done
}

docker compose pull
docker compose -f docker-compose.liveaction.yml pull
docker compose down -v
docker compose -f docker-compose.liveaction.yml down -v

rm -fr data
rm -fr logs
rm -fr customerlogs

# Main script logic
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <logfile.zip>"
  exit 1
fi

unzip -o "$1" -d customerlogs

# Start unzipping from the specified directory
recursive_unzip "customerlogs"
recursive_unzip "customerlogs"
echo "All zip files have been processed."

 docker run -d -p 8000:8000 -p 4318:4318 -p 4317:4317 -p 8080:8080 -p 8002:8002 hyperdx/hyperdx-local
#docker compose up -d
#wait for hyperdx to start
sleep 30
docker compose -f docker-compose.liveaction.yml up -d

