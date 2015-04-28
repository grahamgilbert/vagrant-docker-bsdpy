#!/bin/bash
IP=`ifconfig eth1 2>/dev/null|awk '/inet addr:/ {print $2}'|sed 's/addr://'`
echo $IP
# Install Docker
curl -sSL https://get.docker.com/ubuntu/ | sudo sh

# Pull latest versions of your images
docker pull bruienne/bsdpy:1.0
docker pull macadmins/netboot-httpd
docker pull macadmins/tftpd

# Stop and delete all existing containers
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
sleep 5

docker run -d \
  -v /usr/local/docker/nbi:/nbi \
  --name="web" \
  --restart="always" \
  -p 0.0.0.0:80:80 \
  macadmins/netboot-httpd

docker run -d \
  -p 0.0.0.0:69:69/udp \
  -v /usr/local/docker/nbi:/nbi \
  --name tftpd \
  --restart="always" \
  macadmins/tftpd

docker run -d \
  -p 0.0.0.0:67:67/udp \
  -v /usr/local/docker/nbi:/nbi \
  # -e DOCKER_BSDPY_IP=$IP \
  # -e DOCKER_BSDPY_IFACE=eth1 \
  -e BSDPY_IFACE=eth1 \
  -e BSDPY_NBI_URL=http://$IP \
  -e BSDPY_IP=$IP \
  --name bsdpy \
  --restart=always \
  bruienne/bsdpy:1.0
