#!/bin/bash

TIME_RUN_DEVOPS=$(date +%s)

echo "##########################################################"
echo "####       Installing DevOps tools                    ####"
echo "##########################################################"

# Disable pointless daemons
systemctl stop snapd snapd.socket lxcfs snap.amazon-ssm-agent.amazon-ssm-agent
systemctl disable snapd snapd.socket lxcfs snap.amazon-ssm-agent.amazon-ssm-agent

# Disable swap to make K8s happy
swapoff -a
sed -i '/swap/d' /etc/fstab

printf "*** Installing utilities *** \n\n"

printf ">>> Installing git, awscli, curl, jq, unzip, software-properties-common (apt-add-repository) and sudo \n"
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y git awscli curl jq unzip software-properties-common sudo apt-transport-https
printf ">>> Instalation of utilities completed \n\n"

printf "*** Installing initial devops tools *** \n\n"

printf ">>> Installing docker.io \n"
DEBIAN_FRONTEND=noninteractive apt-get install -y docker.io
apt-mark hold docker.io

# Point Docker at big ephemeral drive and turn on log rotation
systemctl stop docker
mkdir /mnt/docker
chmod 711 /mnt/docker
cat <<EOF > /etc/docker/daemon.json
{
    "data-root": "/mnt/docker",
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "10m",
        "max-file": "5"
    }
}
EOF
systemctl start docker
systemctl enable docker

# Work around the fact spot requests can't tag their instances
REGION=$(ec2metadata --availability-zone | rev | cut -c 2- | rev)
INSTANCE_ID=$(ec2metadata --instance-id)
aws --region $REGION ec2 create-tags --resources $INSTANCE_ID --tags "Key=Name,Value=${instancename}_spot" "Key=Environment,Value=${instancename}_spot"

# Pass bridged IPv4 traffic to iptables chains
service procps start

printf ">>> Instalation of initial devops tools completed \n\n"

printf "*** Downloading DevOps tools installer *** \n\n"

DEFAULT_USER="ubuntu"
wget -q https://raw.githubusercontent.com/chilcano/how-tos/master/resources/setting_devops_tools.sh
chmod +x setting_devops_tools.sh
mv setting_devops_tools.sh /home/$DEFAULT_USER/
printf ">>> The setting_devops_tools.sh was downloaded successfully, now run it: \n"
printf ">>> \t$ . setting_devops_tools.sh \n\n"

printf "\t** Duration of DevOps tools installation: $((($(date +%s)-$${TIME_RUN_DEVOPS}))) seconds.\n\n"

