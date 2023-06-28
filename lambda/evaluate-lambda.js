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