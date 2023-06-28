import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import {
    DynamoDBDocumentClient,
    UpdateCommand
} from "@aws-sdk/lib-dynamodb";
import {
    ReceiveMessageCommand,
    DeleteMessageCommand,
    GetQueueUrlCommand,
    SQSClient,
} from "@aws-sdk/client-sqs";

const sqsClient = new SQSClient({});
const SQS_QUEUE_NAME = 'submissionQ';
const SQS_QUEUE_NAME2 = 'scoreQ';

const client = new DynamoDBClient({});
const dynamo = DynamoDBDocumentClient.from(client);
const tableName = "submission";

const getQueueURL = async (queueName) => {
    const command = new GetQueueUrlCommand({ QueueName: queueName });
    const response = await sqsClient.send(command);
    console.log('Submission Queue URL', response);

    return response;
};

const SQS_QUEUE_URL = getQueueURL(SQS_QUEUE_NAME);

const receiveMessage = (queueUrl) =>
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import {
    DynamoDBDocumentClient,
    UpdateCommand
} from "@aws-sdk/lib-dynamodb";
import {
    ReceiveMessageCommand,
    DeleteMessageCommand,
    GetQueueUrlCommand,
    SQSClient,
} from "@aws-sdk/client-sqs";

const sqsClient = new SQSClient({});
const SQS_QUEUE_NAME = 'submissionQ';
const SQS_QUEUE_NAME2 = 'scoreQ';

const client = new DynamoDBClient({});
const dynamo = DynamoDBDocumentClient.from(client);
const tableName = "submission";

const getQueueURL = async (queueName) => {
    const command = new GetQueueUrlCommand({ QueueName: queueName });
    const response = await sqsClient.send(command);
    console.log('Submission Queue URL', response);

    return response;
};

const SQS_QUEUE_URL = getQueueURL(SQS_QUEUE_NAME);

const receiveMessage = (queueUrl) =>
    client.send(
        new ReceiveMessageCommand({
            AttributeNames: ["SentTimestamp"],
            MaxNumberOfMessages: 10,
            MessageAttributeNames: ["All"],
            QueueUrl: queueUrl,
            VisibilityTimeout: 20,
            WaitTimeSeconds: 5,
        })
    );

const processMessage = async (body) => {

    // 3rd party API Integration Code for evaluating solutions

    let command = new UpdateCommand({
        TableName: tableName,
        Key: {
            submissionID: body.submissionID,
        },
        UpdateExpression: "set status = :status",
        ExpressionAttributeValues: {
            ":status": "EXECUTING",
        },
        ReturnValues: "ALL_NEW",
    });

    let response = await dynamo.send(command);
    console.log('Processing Message in submissionQ',response);

    // check with API()

    // updating solution status - if solution is correct


};

export const handler = async (queueUrl = SQS_QUEUE_URL) => {
    const { Messages } = await receiveMessage(queueUrl);

    if (Messages) {
        for (const m of Messages) {
            console.log('Message received by submissionQ',m.Body)
            await processMessage(m.Body)
            await client.send(
                new DeleteMessageCommand({
                    QueueUrl: queueUrl,
                    ReceiptHandle: m.ReceiptHandle,
                })
            );
        }
    }
};
};

export const handler = async (queueUrl = SQS_QUEUE_URL) => {
    const { Messages } = await receiveMessage(queueUrl);

    if (Messages) {
        for (const m of Messages) {
            console.log('Message received by submissionQ',m.Body)
            await processMessage(m.Body)
            await client.send(
                new DeleteMessageCommand({
                    QueueUrl: queueUrl,
                    ReceiptHandle: m.ReceiptHandle,
                })
            );
        }
    }
};