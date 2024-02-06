#!  /bin/bash

cd /home/chronos

sudo git clone https://github.com/OpenSrcerer/paddy-infrastructure.git

cd ./paddy-infrastructure/docker

sudo curl -sSL \
"https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-linux-x86_64" \
-o docker-compose

# Get environment variables
export BACKEND_MQTT_HOST=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/backend_mqtt_host)
export BACKEND_MQTT_PORT=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/backend_mqtt_port)
export BACKEND_MQTT_SUBSCRIPTIONS=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/backend_mqtt_subscriptions)
export BACKEND_MQTT_AUTHENTICATION_KEY=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/backend_mqtt_authentication_key)

# Loop till docker starts up lmao
SUCCESS=0
ATTEMPTS=0

until [ $SUCCESS -eq 1 ] || [ $ATTEMPTS -eq 10 ]; do
  sudo -E docker-compose up -d && SUCCESS=1 || ATTEMPTS=$((ATTEMPTS + 1))
  sleep 10
done

if [ $SUCCESS -eq 0 ]; then
  cd ../../
  echo "Docker didn't boot up in time, exiting..." >> error.txt
  exit 1
fi