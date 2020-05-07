## Creating an Affordable Remote DevOps Desktop with AWS CloudFormation

### Steps

1. Go to directory.  
   ```sh
   $ cd gitrepos/affordable-remote-desktop/resources/cloudformation
   ```
   
2. Convert JSON to YAML (optional).  
   ```sh
   $ ruby -ryaml -rjson -e 'puts YAML.dump(JSON.load(ARGF))' < affordable-ec2.json > affordable-ec2.yaml
   ```
 
3. Creating the CloudFormation Stack.  
   ```sh
   $ export AWS_ACCESS_KEY_ID="xxxxxx"; export AWS_SECRET_ACCESS_KEY="yyyyyyy"
   $ export AWS_DEFAULT_REGION="us-east-1"
   ```
   Create the stack.  
   ```sh
   $ aws cloudformation create-stack --template-body file://affordable-ec2.yaml --stack-name Affordable-Remote-DevOps-Desktop --parameters ParameterKey=KeyName,ParameterValue=chilcan0 
   
   {
       "StackId": "arn:aws:cloudformation:us-east-1:263455585760:stack/Affordable-Remote-DevOps-Desktop/768bd810-9093-11ea-b441-0e58925d1f8e"
   }
   ```
   
4. Getting access to the EC2 instance through SSH.  
   First of all, get the FQDN (PublicDNS)
   ```sh
   $ aws cloudformation describe-stacks --stack-name Affordable-Remote-DevOps-Desktop --query "Stacks[0].Outputs[0]"
   {
       "OutputKey": "FQDNRemoteDevOpsDesktop",
       "OutputValue": "ec2-XYZ.compute-1.amazonaws.com",
       "Description": "FQDN for newly created RemoteDevOpsDesktop"
   }
   ```
   Now, connect to FQDN
   ```sh
   $ chmod 400 ~/.ssh/chilcan0.pem
   
   $ ssh ubuntu@$"ec2-XYZ.compute-1.amazonaws.com" -i ~/.ssh/chilcan0.pem
   Welcome to Ubuntu 18.04.4 LTS (GNU/Linux 5.3.0-1017-aws x86_64)
   ...
   
   ubuntu@ip-172-31-42-202:~$ 
   ```
   
5. Cleanup.  
   ```sh
   $ aws cloudformation delete-stack --stack-name Affordable-Remote-DevOps-Desktop
   ```
   
6. Rerun the stack providing a [Bash script](install_devops.sh) as `UserData` to install all DevOps tools.  
   ```sh
   $ aws cloudformation update-stack \
     --template-body file://affordable-ec2.yaml \
     --stack-name Affordable-Remote-DevOps-Desktop \
     --parameters ParameterKey=KeyName,ParameterValue=chilcan0 ParameterKey=UserData,ParameterValue=$(base64 -w0 install_devops.sh) 
   ```
   
   But if this is the first time you are running CloudFormation, then use this command:
   ```sh
   $ aws cloudformation create-stack \
     --template-body file://affordable-ec2.yaml \
     --stack-name Affordable-Remote-DevOps-Desktop \
     --parameters ParameterKey=KeyName,ParameterValue=chilcan0 ParameterKey=UserData,ParameterValue=$(base64 -w0 install_devops.sh) 
   ```
   
   Since the CloudFormation template has been updated (Output section updated and loading a bash script), we are going to execute CloudFormation with the flag `update-stack` instead of `create-stack`.
   
7. Checking the provisioning process.  
   Once finished the `update-stack` or `create-stack` process, get the FQDN, connect to It through SSH and execute the below command.
   ```sh
   $ aws cloudformation describe-stacks --stack-name Affordable-Remote-DevOps-Desktop --query "Stacks[0].Outputs[0].OutputValue"
   "ec2-XYZ.compute-1.amazonaws.com"
   
   $ ssh ubuntu@$"ec2-XYZ.compute-1.amazonaws.com" -i ~/.ssh/chilcan0.pem
   
   ubuntu@ip-172-31-42-202:~$ tail -f /var/log/cloud-init-output.log
   
   Setting up code (1.45.0-1588868285) ...
   Processing triggers for desktop-file-utils (0.23-1ubuntu3.18.04.2) ...
   Processing triggers for mime-support (3.60ubuntu1) ...
   ->>> Installing Terraform
   Archive:  terraform_0.12.24_linux_amd64.zip
     inflating: terraform               
     ** Duration of DevOps tools installation: 105 seconds.
   
   Cloud-init v. 19.4-33-gbb4131a2-0ubuntu1~18.04.1 running 'modules:final' at Thu, 07 May 2020 22:16:17 +0000. Up 20.58 seconds.
   ```
   