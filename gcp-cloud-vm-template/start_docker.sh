#!  /bin/bash

# Step 1: Install Compose
sudo curl -sSL \
"https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-linux-x86_64" \
-o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

cat << 'EOF' | sudo tee /etc/profile.d/docker_compose.sh
#!/bin/bash
export PATH=$PATH:/usr/local/bin
EOF

sudo chmod +x /etc/profile.d/docker_compose.sh
source /etc/profile.d/docker_compose.sh

# Step 2: Run actual apps

cd /home/chronos

sudo git clone https://github.com/OpenSrcerer/paddy-infrastructure.git

cd ./paddy-infrastructure/docker

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