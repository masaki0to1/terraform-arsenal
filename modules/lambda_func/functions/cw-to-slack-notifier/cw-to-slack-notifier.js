const { rejects } = require('assert');
const https = require('https');
const { type, hostname } = require('os');
const path = require('path');
const { resolve } = require('path');
const { stringify } = require('querystring');
const { text } = require('stream/consumers');
const { RetryAgent } = require('undici-types');
const url = require('url')

/** 
 * @param {Object} event
 * @returns {Object}
 */

exports.handler = async (event) => {
  console.log('Received event:', JSON>stringify(event, null, 2));

  try {
    // Validate the event structure
    if (!event.Records || !Array.isArray(event.Records) || event.Records.length ===0) {
      throw new Error('Invalid event structure: missing Records array');
    }

    // Process each record in the event 
    const results = await Promise.all(event.Records.map(async (record) => {
      const message = JSON.parse(record.Sns.Message);
      console.log('Processing message:', JSON.stringify(message, null, 2));

      // Validate the message structure
      if (!message.AlarmName || !message.NewStateValue || !message.NewStateReason) {
        throw new Error('Invalid message structure: missing required fields');
      }
      const { AlarmName: alarmName } = message;

      // Determine the appropriate Slack Webhook URL based on the alarm name
      const webhookUrl = determineWebhookUrl(alarmName);
        if (!webhookUrl) {
          throw new Error(`No webhook URL found for alarm: ${alarmName}`);
        }
      const slackMessage = createSlackMessage(message);

      // Send the notification to Slack
      await sendSlackNotification(webhookUrl, slackMessage);
      
      return `Processed alarm: ${alarmName}`;
    }));

    console.log('Processing results:', results);

    return {
      statusCode: 200,
      body: JSON.stringify(`Successfully processed ${results.length} message(s)`)
    };
  } catch (error) {
    console.error('Error processing event:', error);
    return {
      statusCode: 500,
      body: JSON.stringify('Error processing notification(s): ' + error.message)
    };
  }
};

/** 
 * @param {string} alarmName
 * @returns {string|null}
 */

function determineWebhookUrl(alarmName) {
  const lowerAlarmName = alarmName.toLowerCase();

  if (lowerAlarmName.includes('amplify')) {
    return process.env.AMPLIFY_ERROR_WEBHOOK;
  } else if (lowerAlarmName.includes('backend')) {
    return process.env.BACKEND_ERROR_WEBHOOK;
  } else if (lowerAlarmName.includes('batch') && lowerAlarmName.includes('error')) {
    return process.env.BATCH_ERROR_WEBHOOK;
  } else if (lowerAlarmName.includes('batch') && lowerAlarmName.includes('warning')) {
    return process.env.BATCH_WARNING_WEBHOOK;
  } else {
    console.log(`Unknown alarm type: ${alarmName}`);
    return null;
  }
}

/** 
 * @param {string} webhookUrl
 * @param {Object} message
 * @returns {Promise<string>}
 */

function createSlackMessage(message) {
  const { AlarmName, NewStateReason, NewStateValue, StateChangeTime, AWSAccountId, Region } = message;

  const logGroupName = encodeURIComponent(`/aws/lambda/${process.env.AWS_LAMBDA_FUNCTION_NAME}`);
  const logStreamName = encodeURIComponent(process.env.AWS_LAMBDA_LOG_STREAM_NAME);
  const logLink = `https://${Region}.console.aws.amazon.com/cloudwatch/home?region=${Region}#logsV2:log-groups/log-group/${logGroupName}/log-events/${logStreamName}`;

  const severityEmoji = NewStateValue === 'ALARM' ? ':red_circle:' : ':warning:';

  const isTestMessage = NewStateReason.toLowerCase().includes('test');

  let mention = '';

  if (isTestMessage) {
    mention = process.env.TEST_ALARM_MENTION || '<!test user name>';
  }

  // Decide to whom to mentions.
  if (!isTestMessage && NewStateValue === 'ALARM') {
    if (AlarmName.toLowerCase().includes('error')) {
      mention = process.env.ERROR_ALARM_MENTION || '<!channel>';
    } else if (AlarmName.toLowerCase().includes('warning')) {
      mention = process.env.WARNING_ALARM_MENTION || '<!here>';
    } else {
      // Default behavior for unknown alarm type
      mention = process.env.DEFAULT_ALARM_MENTION || '<!here>';
    }
  }

  return {
    blocks: [
      {
        type: "section",
        text: {
          type: "mrkdwn",
          text: `${severityEmoji} *Alarm: ${AlarmName}*\n${mention}`
        }
      },
      {
        type: "section",
        fields: [
          {
            type: "mrkdwn",
            text: `*State:*\n${NewStateValue}`
          },
          {
            type: "mrkdwn",
            text: `*Time:*\n${StateChangeTime}`
          },
          {
            type: "mrkdwn",
            text: `*Account:*\n${AWSAccountId}`
          },
          {
            type: "mrkdwn",
            text: `*Region:*\n${Region}`
          }
        ]
      },
      {
        type: "section",
        text: {
          type: "mrkdwn",
          text: `*Reason:*\n${NewStateReason}`
        }
      },
      {
        type: "actions",
        elements: [
          {
            type: "button",
            text: {
              type: "plain_text",
              text: "View Logs"
            },
            url: logLink
          }
        ]
      }
    ]
  };
}

function sendSlackNotification(webhookUrl, message) {
  return new Promise((resolve, reject) => {
    const requestUrl = url.parse(webhookUrl);
    const options = {
      hostname: requestUrl.hostname,
      port: 443,
      path: requestUrl.path,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      }
    };

    const req = https.request(options, (res) => {
      let responceBody = '';

      res.on('data', (chunk) => {
        responceBody += chunk;
      });

      res.on('end', () => {
        if (res.statusCode === 200) {
          console.log('Slack notification sent successfully');
          resolve('Message sent to Slack successfully');
        } else {
          console.error(`Failed to send Slack notification. Status: ${res.statusCode}, Response: ${responseBody}`);
          reject(new Error(`Failed to send Slack notification. Status: ${res.statusCode}`));
        }
      });
    });

    req.on('error', (e) => {
      console.error('Error sending Slack notification:', e);
      reject(new Error(`Error sending message to Slack: ${e.message}`));
    });

    req.write(JSON.stringify(message));
    req.end();
  });
}