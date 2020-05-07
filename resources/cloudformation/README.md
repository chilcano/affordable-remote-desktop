## Creating an Affordable Remote DevOps Desktop with AWS CloudFormation

1. Go to directory.

```sh
$ cd gitrepos/affordable-remote-desktop/resources/cloudformation
```

2. Convert JSON to YAML (optional).
3. 
```sh
$ ruby -ryaml -rjson -e 'puts YAML.dump(JSON.load(ARGF))' < affordable-ec2.json > affordable-ec2.yaml
```

3. Creating the CloudFormation Stack.

```sh
$ export AWS_ACCESS_KEY_ID="xxxxxx"; export AWS_SECRET_ACCESS_KEY="yyyyyyy"
$ export AWS_DEFAULT_REGION="us-east-1"
```

Create the stack
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

Since the CloudFormation template has been updated (Output section updated and loading a bash script), we are going to execute CloudFormation with the flag `update-stack` instead of `create-stack`.

7. Checking the provisioning process.

Once finished the `update-stack` or `create-stack` process, get the FQDN, connect to It through SSH and execute the below command.
```sh
$ aws cloudformation describe-stacks --stack-name Affordable-Remote-DevOps-Desktop --query "Stacks[0].Outputs[0].OutputValue"
"ec2-XYZ.compute-1.amazonaws.com"

$ ssh ubuntu@$"ec2-XYZ.compute-1.amazonaws.com" -i ~/.ssh/chilcan0.pem

ubuntu@ip-172-31-42-202:~$ tail -f /var/log/cloud-init-output.log
```

END.