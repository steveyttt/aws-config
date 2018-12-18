/**
* A sample Lambda function that parses SNS messages and pushes them to Slack
* Requires two environment variables (one for slack channel and one for slack webhook URL)
**/

// Add the https module - https://nodejs.org/api/https.html
// Add the url module - https://nodejs.org/api/url.html
// We need these to get node to make calls to url's
const https = require("https");
const url = require("url");

exports.handler = function(event, context) {
  //Log the first message to say received
  console.log("REQUEST RECEIVED:\n" + JSON.stringify(event));
  // Call the send response function with 2 parameters
  sendResponse(event, context);
}

function sendResponse(event, context) {
  // Creates a variable which is a JSON string (json)
  // This is the response to send to the slack channel
  if (event.source == 'aws.codepipeline') {
      console.log("PIPELINE RULE TO BE PROCESSED")
      var messageColour = "good"
      if (event.detail.state == "FAILED" )
        {
          var messageColour = "danger"
        }
      var responseBody = JSON.stringify({
        channel: process.env.slackchannel,
        text: ":tractor:" + event["detail-type"] + ":tractor:",
        attachments: [{
          author_name: "AWS-Code-Pipeline",
          color: messageColour,
          fields: [{
            title: 'PIPELINE-NAME',
            value: event.detail.pipeline,
            short: false,
          },{
            title: 'STATE',
            value: event.detail.state,
            short: true,
          }, {
            title: 'STAGE',
            value: event.detail.stage,
            short: true,
          }],
        }]
      });
    }
    else  {
      console.log("CONFIG RULE TO BE PROCESSED")
      var messageColour = "good"
      if (event.detail.newEvaluationResult.complianceType == "NON_COMPLIANT" )
        {
          var messageColour = "danger"
        }
      var responseBody = JSON.stringify({
        channel: process.env.slackchannel,
        text: ":fire_engine:" + event["detail-type"] + ":fire_engine:",
        attachments: [{
          author_name: "AWS-Config",
          color: messageColour,
          fields: [{
            title: 'RESOURCE',
            value: event.detail.resourceId,
            short: true,
          }, {
            title: 'REGION',
            value: event.detail.awsRegion,
            short: true,
          }, {
            title: 'CONFIGRULENAME',
            value: event.detail.configRuleName,
            short: true,
          }, {
            title: 'COMPLIANCE',
            value: event.detail.newEvaluationResult.complianceType,
            short: true,
          }],
        }]
      });
    }

  // The url.parse() method takes a URL string, parses it, and returns a json object.
  // A var is then created that stores the url call as a json object
  var parsedUrl = url.parse(process.env.slackurl);
  var options = {
      hostname: parsedUrl.hostname,
      port: 443,
      path: parsedUrl.path,
      method: "POST",
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(responseBody),
      }
  };

  // Quick message to say it is sending a response
  console.log("SENDING RESPONSE...\n");

  // Construct a request to make a call to a web server
  // Output the status code and the headers (These go into cloudwatch)
  var request = https.request(options, function(response) {
    console.log("STATUS: " + response.statusCode);
    console.log("HEADERS: " + JSON.stringify(response.headers));
    context.done();
});

  // Uses the request variable to output any error responses to cloudwatch
  request.on("error", function(error) {
      console.log("sendResponse Error:" + error);
      // Tell AWS Lambda that the function execution is done
      context.done();
  });

  // This will push the data to the remote location that CF will check
  request.write(responseBody);
  request.end();
} 