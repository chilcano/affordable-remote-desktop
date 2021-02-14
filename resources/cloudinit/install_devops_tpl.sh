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

echo "----------------------------------------------------------"
echo "|                Installing utilities                    |"
echo "----------------------------------------------------------"

printf "==> Installing git, awscli, curl, jq, unzip, software-properties-common (apt-add-repository) and sudo \n"
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y git awscli curl jq unzip software-properties-common sudo apt-transport-https

echo "----------------------------------------------------------"
echo "|        Installing initial devops tools                 |"
echo "----------------------------------------------------------"

printf "==> Installing docker.io \n"
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

printf "==> Applying workaround. Seeting AWS tags \n"
# Work around the fact spot requests can't tag their instances
REGION=$(ec2metadata --availability-zone | rev | cut -c 2- | rev)
INSTANCE_ID=$(ec2metadata --instance-id)
aws --region $REGION ec2 create-tags --resources $INSTANCE_ID --tags "Key=Name,Value=${instanceName}_spot" "Key=Environment,Value=${instanceName}_spot"

# Pass bridged IPv4 traffic to iptables chains
service procps start

echo "----------------------------------------------------------"
echo "|        Downloading devops tools installer              |"
echo "----------------------------------------------------------"
 
DEFAULT_USER="ubuntu"
wget -q https://raw.githubusercontent.com/chilcano/how-tos/master/resources/devops_tools_install_v1.sh
chmod +x devops_tools_install_v1.sh
mv devops_tools_install_v1.sh /home/$DEFAULT_USER/
printf "==> The devops_tools_install_v1.sh was downloaded successfully, now run it: \n"
printf "==> \t$ . devops_tools_install_v1.sh \n\n"

printf "\t Duration: $((($(date +%s)-$${TIME_RUN_DEVOPS}))) seconds.\n\n"
