#!/bin/bash
echo "Starting preloader script..."

# Create folder for ignite to actually boot
mkdir -p "./versions/$MINECRAFT_VERSION"

if [ "$ALWAYS_UPDATE" = "1" ]; then
  # Automatic updater is enabled, try to update ASPaper and igniteMC jars
  echo -e "Finding server jar download..."
  if [ -n "${DOWNLOAD_PATH}" ]; then
    echo -e "Using supplied download url: ${DOWNLOAD_PATH}"
    DOWNLOAD_URL=`eval echo $(echo ${DOWNLOAD_PATH} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
  else
    API_BASE="https://api.infernalsuite.com/v1/projects/asp/mcVersion"
      
    echo -e "Checking version availability..."
      
    JSON=$(curl -s "${API_BASE}/${MINECRAFT_VERSION}")
      
    if [ -z "$JSON" ] || [[ "$JSON" == "[]" ]]; then
        echo -e "Specified version not found. Attempting fallback to latest available version..."
        exit 1
    else
        echo -e "Version is valid. Using version ${MINECRAFT_VERSION}"
    fi
      
    echo -e "Resolving latest main branch build..."
      
    # neuesten main branch build holen
    PROJECT_ID=$(echo "$JSON" | jq -r '
    map(select(.branch == "main"))
    | sort_by(.date)
    | last
    | .id
    ')
      
    if [ -z "$PROJECT_ID" ] || [ "$PROJECT_ID" == "null" ]; then
      echo -e "No main branch build found!"
      exit 1
    fi
      
    echo -e "Using project/build ID: ${PROJECT_ID}"
      
    # dazugehörige Files holen und asp-server.jar bestimmen
    FILE_ID=$(echo "$JSON" | jq -r --arg pid "$PROJECT_ID" '
    map(select(.id == $pid))
    | .[0].files
    | map(select(.fileName == "asp-server.jar"))
    | sort_by(.uploadDate)
    | last
    | .id
    ')
      
    if [ -z "$FILE_ID" ] || [ "$FILE_ID" == "null" ]; then
      echo -e "No asp-server.jar found for this build!"
      exit 1
    fi
      
    echo -e "Using file ID: ${FILE_ID}"
      
    # Name festlegen (API gibt keinen sauberen Build-Namen wie Paper zurück)
    JAR_NAME="asp-server-${MINECRAFT_VERSION}.jar"
    
    echo -e "Version being downloaded"
    echo -e "MC Version: ${MINECRAFT_VERSION}"
    echo -e "Project ID: ${PROJECT_ID}"
    echo -e "File ID: ${FILE_ID}"
    echo -e "JAR Name: ${JAR_NAME}"
      
    DOWNLOAD_URL="https://api.infernalsuite.com/v1/projects/asp/${PROJECT_ID}/download/${FILE_ID}"
  fi
  
  cd /mnt/server
  
  echo -e "Trying to download ignite jar..."
  
  REPO_OWNER=vectrix-space
  REPO_NAME=ignite
  GITHUB_API_URL=https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest
  IGNITE_API_RESPONSE=`curl -s ${GITHUB_API_URL}`
  IGNITE_DOWNLOAD_URL=$(echo "$IGNITE_API_RESPONSE" | grep -o '"browser_download_url": "[^"]*ignite\.jar' | sed 's/"browser_download_url": "//')
  if [ -n "${IGNITE_DOWNLOAD_URL}" ]; then
    if [ -f "ignite.jar" ]; then
      echo -e "Archiving old ignite jar..."
      mv "ignite.jar" "ignite.jar.old"
    fi
    echo -e "Downloading ignite jar..."
    curl -L -o ignite.jar ${IGNITE_DOWNLOAD_URL}    
  else
    echo -e "Could not find download URL for ignite!"
  fi
  
  echo -e "Running curl -o ${SERVER_JAR_FILE} ${DOWNLOAD_URL}"
  
  if [ -f ${SERVER_JAR_FILE} ]; then
    echo -e "Archiving server jar..."
    mv ${SERVER_JAR_FILE} ${SERVER_JAR_FILE}.old
  fi
  
  curl -o ${SERVER_JAR_FILE} ${DOWNLOAD_URL}
fi

# Your custom code can begin here
echo "Finished preloader script!"
