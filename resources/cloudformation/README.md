## Creating an Affordable Remote DevOps Desktop with AWS CloudFormation

1. Go to directory

```sh
$ cd gitrepos/affordable-remote-desktop/resources/cloudformation
```

2. Convert JSON to YAML (optional)
```sh
$ ruby -ryaml -rjson -e 'puts YAML.dump(JSON.load(ARGF))' < affordable-ec2.json > affordable-ec2.yml
```

3. Creating the CloudFormation Stack

```sh
$ export AWS_ACCESS_KEY_ID="xxxxxx"; export AWS_SECRET_ACCESS_KEY="yyyyyyy"
$ export AWS_DEFAULT_REGION="us-east-1"
```

Create the stack
```sh
$ aws cloudformation create-stack --template-body file://affordable-ec2.yml --stack-name Affordable-Remote-DevOps-Desktop --parameters ParameterKey=KeyName,ParameterValue=chilcan0 

{
    "StackId": "arn:aws:cloudformation:us-east-1:263455585760:stack/Affordable-Remote-DevOps-Desktop/768bd810-9093-11ea-b441-0e58925d1f8e"
}
```

4. Getting access to EC2 instance through SSH

```sh
$ chmod 400 ~/.ssh/chilcan0.pem

$ ssh ubuntu@$"ec2-XYZ.compute-1.amazonaws.com" -i ~/.ssh/chilcan0.pem
Welcome to Ubuntu 18.04.4 LTS (GNU/Linux 5.3.0-1017-aws x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Thu May  7 20:09:20 UTC 2020

  System load:  0.37              Processes:           98
  Usage of /:   28.4% of 7.69GB   Users logged in:     0
  Memory usage: 9%                IP address for eth0: 172.31.42.202
  Swap usage:   0%

 * Ubuntu 20.04 LTS is out, raising the bar on performance, security,
   and optimisation for Intel, AMD, Nvidia, ARM64 and Z15 as well as
   AWS, Azure and Google Cloud.

     https://ubuntu.com/blog/ubuntu-20-04-lts-arrives


0 packages can be updated.
0 updates are security updates.


Last login: Thu May  7 20:07:30 2020 from 83.46.129.81
ubuntu@ip-172-31-42-202:~$ 
```