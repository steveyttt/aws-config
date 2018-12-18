# README #

### What is This Repo For? ###

This REPO hosts all the necessary files to deploy a working AWS config rule engine into an AWS account. Once your account is created you can run the deploy.sh script in the /deploy folder.

All CF templates are setup in their own folder. Where possible CF import functions are used to reduce th amount of parameters.

Please note that all stacks in deploy.sh are deployed using the AWS CLI. However AWS Config rules are deployed using build pipeline. Pipeline rules can be quickly iterated over using the native pipeline over the CLI.

### What resources are used? ###
**S3** is used to store config, build pipeline & lambda assets
**SNS** is used to store the SNS notification topic for AWS Config
**cloudwatch events** are used to created an event stream which lambda can tap into to send notifications
**Config** is used to create config rules which can scan the AWS resources for insecurities.
**IAM** is used to create the necessary roles for AWS config
**Lambda** is used to create a lambda function which takes event stream messages from cloudwatch and passes them to slack

### How do I get set up? ###
The deploy.sh needs running to get setup. Inputs are used heavily and the params files will need modifying to suit your account. Please search the REPO for {accountid} and replace where appropriate. If you rename a stack which is referenced in an import you will need to modify the CF to accomodate it. 

Before you deploy your lambda function you will need a slack channel with a webhook app and a URL to hit. These are provided as env vars to the lambda function. View the slack links below for help.

Once all stacks have been deployed and code uploaded you should see active rules running and slack messages populated into your slack channel.

### Handy Links ###
### Slack ###
https://api.slack.com/custom-integrations/incoming-webhooks && https://api.slack.com/slack-apps
https://api.slack.com/docs/messages && https://api.slack.com/docs/message-attachments

### Code Pipeline ###
https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/continuous-delivery-codepipeline-basic-walkthrough.html

### Cookie custom aws config rules ###
https://docs.aws.amazon.com/config/latest/developerguide/aws-config-managed-rules-cloudformation-templates.html

### To delete and rebuild aws config ###
https://docs.aws.amazon.com/config/latest/developerguide/stop-start-recorder.html
Delete the config recorder:
aws configservice describe-configuration-recorders
aws configservice delete-configuration-recorder --configuration-recorder-name default

### AWS event stream ###
https://docs.aws.amazon.com/codepipeline/latest/userguide/detect-state-changes-cloudwatch-events.html