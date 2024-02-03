#!  /bin/bash

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl git -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

cd /home/ubuntu

sudo git clone https://github.com/OpenSrcerer/paddy-infrastructure.git

cd ./paddy-infrastructure/docker-paddy

# Get environment variables
BACKEND_MQTT_HOST=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/BACKEND_MQTT_HOST)
BACKEND_MQTT_PORT=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/BACKEND_MQTT_PORT)
BACKEND_MQTT_SUBSCRIPTIONS=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/BACKEND_MQTT_SUBSCRIPTIONS)

# Loop till docker starts up lmao
SUCCESS=0
ATTEMPTS=0

until [ $SUCCESS -eq 1 ] || [ $ATTEMPTS -eq 10 ]; do
  sudo docker compose up -d && SUCCESS=1 || ATTEMPTS=$((ATTEMPTS + 1))
  sleep 10
done

if [ $SUCCESS -eq 0 ]; then
  cd ../../
  echo "Docker didn't boot up in time, exiting..." >> error.txt
  exit 1
fi