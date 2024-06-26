#!  /bin/bash

cd /home/chronos

sudo git clone https://github.com/OpenSrcerer/paddy-infrastructure.git

cd ./paddy-infrastructure/docker

# Pull compose and run with environment variables
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v "$PWD:/$PWD" -w="/$PWD" \
  -e BACKEND_MQTT_HOST=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/backend_mqtt_host) \
  -e BACKEND_MQTT_PORT=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/backend_mqtt_port) \
  -e BACKEND_MQTT_DEVICE_READ_TOPIC=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/backend_mqtt_device_read_topic) \
  -e BACKEND_MQTT_AUTHENTICATION_KEY=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/backend_mqtt_authentication_key | tr -d '\n') \
  docker/compose:latest -f auth-docker-compose.yml up -d