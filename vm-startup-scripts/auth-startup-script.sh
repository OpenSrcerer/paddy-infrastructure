#!  /bin/bash

cd /home/chronos

sudo git clone https://github.com/OpenSrcerer/paddy-infrastructure.git

cd ./paddy-infrastructure/docker

# Pull compose and run with environment variables
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v "$PWD:/$PWD" -w="/$PWD" \
  -e BACKEND_MQTT_AUTHENTICATION_KEY=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/backend_mqtt_authentication_key | tr -d '\n') \
  -e BACKEND_DB_URI=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/backend_db_uri) \
  -e BACKEND_DB_USER=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/backend_db_user) \
  -e BACKEND_DB_PASSWORD=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/backend_db_password) \
  docker/compose:latest -f auth-docker-compose.yml up -d