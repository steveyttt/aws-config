#!/bin/bash
##Validate CF templates
aws cloudformation validate-template --template-body file://../s3/bucket-s3.yaml
aws cloudformation validate-template --template-body file://../lambda/lambda-sns-slack.yaml
aws cloudformation validate-template --template-body file://../cloudwatch/cloudwatch-events-rule.yaml
aws cloudformation validate-template --template-body file://../sns/sns-topic.yaml
aws cloudformation validate-template --template-body file://../iam/iam-role-config.yaml
aws cloudformation validate-template --template-body file://../codepipeline/codepipeline-pipeline.yaml
aws cloudformation validate-template --template-body file://../lambda/lambda-config-cloudtrail.yaml
aws cloudformation validate-template --template-body file://../config/default-config-rule.yaml

##Deploy S3 Buckets
aws cloudformation create-stack \
    --stack-name config-01-dev-master-bucket-s3 \
    --template-body file://../s3/bucket-s3.yaml \
    --tags file://tags.json

#Deploy the Slack Lambda code to an S3 bucket
cd ../lambda
zip -r code.zip .
cd ../deploy
aws s3 cp ../lambda/code.zip s3://lambdabucket-{accountID}/code.zip

#Deploy the lambda function using CF
aws cloudformation create-stack \
    --stack-name config-01-dev-master-lambda-sns-slack \
    --template-body file://../lambda/lambda-sns-slack.yaml \
    --parameters file://../lambda/lambda-sns-slack.params.json \
    --tags file://tags.json \
    --capabilities CAPABILITY_NAMED_IAM

#Deploy the cloudwatch event streams using CF
aws cloudformation create-stack \
    --stack-name config-01-dev-master-cloudwatch-event-rules \
    --template-body file://../cloudwatch/cloudwatch-events-rule.yaml \
    --tags file://tags.json \
    --capabilities CAPABILITY_NAMED_IAM

#Deploy SNS topic for AWS Config messages
aws cloudformation create-stack \
    --stack-name config-01-dev-master-sns-topic-config \
    --template-body file://../sns/sns-topic.yaml \
    --tags file://tags.json

#Deploy IAM role and policy for AWS Config
aws cloudformation create-stack \
    --stack-name config-01-dev-master-iam-role-config \
    --template-body file://../iam/iam-role-config.yaml \
    --tags file://tags.json \
    --capabilities CAPABILITY_NAMED_IAM

#Deploy the pipeline
aws cloudformation create-stack \
    --stack-name config-01-dev-master-codepipeline-pipeline-config \
    --template-body file://../codepipeline/codepipeline-pipeline.yaml \
    --parameters file://../codepipeline/codepipeline-pipeline-params.json \
    --tags file://tags.json \
    --capabilities CAPABILITY_NAMED_IAM

#Enable config
aws configservice subscribe --s3-bucket configbucket-{accountID} \
    --sns-topic {SNS Topic output} \
    --iam-role {IAM role output}}

#Start config
aws configservice start-configuration-recorder --configuration-recorder-name default

#Deploy the lambda function using CF
aws cloudformation create-stack \
    --stack-name config-01-dev-master-lambda-config-cloudtrail \
    --template-body file://../lambda/lambda-config-cloudtrail.yaml \
    --tags file://tags.json \
    --capabilities CAPABILITY_NAMED_IAM

#zip up a config rule
cd ../config
zip -r default-config-rule.yaml.zip .
cd ../deploy

#Copy a zip file to S3 for a deployment
aws s3 cp ../config/default-config-rule.yaml.zip s3://codepipelinebucket-{accountID}/default-config-rule.yaml.zip
