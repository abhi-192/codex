import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import {
    DynamoDBDocumentClient,
    PutCommand
} from "@aws-sdk/lib-dynamodb";
import {
    GetQueueUrlCommand,
    SQSClient
} from "@aws-sdk/client-sqs";

const sqsClient = new SQSClient({});
const SQS_QUEUE_NAME = 'submissionQ';

const client = new DynamoDBClient({});
const dynamo = DynamoDBDocumentClient.from(client);
const tableName = "submission";

const getQueueURL = async (queueName = SQS_QUEUE_NAME) => {
    const command = new GetQueueUrlCommand({ QueueName: queueName });
    const response = await sqsClient.send(command);
    console.log('Submission Queue URL', response);

    return response;
};

export const handler = async (event, context) => {
    let body;
    let statusCode = 200;
    const headers = {
        "Content-Type": "application/json",
    };

    try {
        let requestJSON = JSON.parse(event.body);
        let newID = String(Math.floor((Math.random() * 100000000) + 1)).concat(String(Math.floor((Math.random() * parseInt(requestJSON.userID)))),String(Math.floor((Math.random() * parseInt(requestJSON.contestID)))))
        switch (event.routeKey) {
            case "POST /submit":
                body = await dynamo.send(
                    new PutCommand({
                        TableName: tableName,
                        Item: {
                            submissionID: newID,
                            userID: requestJSON.userID,
                            contestID: requestJSON.contestID,
                            language: requestJSON.language,
                            quesID: requestJSON.quesID,
                            code: requestJSON.code,
                            status: "Compiling",
                            comment: "",
                            weight: 1,
                        }
                    })
                );
                body = `Put item ${newID}`;
                break;
            default:
                throw new Error(`Unsupported route: "${event.routeKey}"`);
        }
        const sqs = new AWS.SQS({ apiVersion: "2012-11-05" });
        sqs.sendMessage({
            MessageBody: JSON.stringify(body),
            QueueUrl: getQueueURL(),
        }, (err, data) => (err) ? console.log("Error", err) : console.log("Successfully pushed to submissionQ", data.MessageId));
    } catch (err) {
        statusCode = 400;
        body = err.message;
    } finally {
        body = JSON.stringify(body);
    }

    return {
        statusCode,
        body,
        headers,
    };
};
