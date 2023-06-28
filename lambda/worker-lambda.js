import { getQueueURL, receiveMessage } from "./evaluate-lambda"
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import {
    DynamoDBDocumentClient,
    UpdateCommand
} from "@aws-sdk/lib-dynamodb";
import {
    DeleteMessageCommand,
} from "@aws-sdk/client-sqs";

const { S3 } = require('aws-sdk');
const SQS_QUEUE_NAME = 'scoreQ';
const client = new DynamoDBClient({});
const dynamo = DynamoDBDocumentClient.from(client);
const tableName = "score";

const updateScore = async(body) => {
};

export const handler = async (queueUrl = getQueueURL(SQS_QUEUE_NAME)) => {
    const { Messages } = await receiveMessage(queueUrl);

    if (Messages) {
        for (const m of Messages) {
            console.log('Message received by submissionQ',m.Body)
            await updateScore(m.Body)
            await client.send(
                new DeleteMessageCommand({
                    QueueUrl: queueUrl,
                    ReceiptHandle: m.ReceiptHandle,
                })
            );
        }
    }
};