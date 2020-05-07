#!/bin/bash

TIME_RUN_DEVOPS=$(date +%s)

echo "##########################################################"
echo "####           Installing the DevOps Tools            ####"
echo "##########################################################"

# Disable pointless daemons
systemctl stop snapd snapd.socket lxcfs snap.amazon-ssm-agent.amazon-ssm-agent
systemctl disable snapd snapd.socket lxcfs snap.amazon-ssm-agent.amazon-ssm-agent

# Disable swap to make K8s happy
swapoff -a
sed -i '/swap/d' /etc/fstab

echo "->>> Installing awscli, jq, docker.io and unzip"
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y awscli jq docker.io unzip software-properties-common apt-transport-https
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

echo "->>> Installing Chromium"
apt-get install -y chromium-browser

echo "->>> Installing Java"
apt-get install -y openjdk-11-jre-headless

echo "->>> Installing VS Code"
wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
apt-get update
apt-get install -y code

echo "->>> Installing Terraform"
#TF_VERSION=0.12.24
#TF_VERSION="0.11.15-oci"
TF_VERSION_LATEST=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r -M '.current_version')
TF_BUNDLE=$(echo terraform_${TF_VERSION_LATEST}_linux_amd64.zip)

wget --quiet https://releases.hashicorp.com/terraform/$TF_VERSION_LATEST/$TF_BUNDLE
unzip $TF_BUNDLE
mv terraform /usr/local/bin/
rm -rf terraf*

printf "\t** Duration of DevOps tools installation: $((($(date +%s)-$TIME_RUN_DEVOPS))) seconds.\n\n"
