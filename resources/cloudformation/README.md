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
$ ssh ubuntu@$ec2-xyz.compute-1.amazonaws.com -i ~/Downloads/chilcan0.pem
```