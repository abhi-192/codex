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

    command = new UpdateCommand({
        TableName: tableName,
        Key: {
            submissionID: body.submissionID,
        },
        UpdateExpression: "set status = :status",
        ExpressionAttributeValues: {
            ":status": "OK",
        },
        ReturnValues: "ALL_NEW",
    });

    await dynamo.send(command);

    // updating solution status - if solution is not correct
    // errorReturned is mistake in code

    let errorReturned = ""
    command = new UpdateCommand({
        TableName: tableName,
        Key: {
            submissionID: body.submissionID,
        },
        UpdateExpression: "set status = :status",
        ExpressionAttributeValues: {
            ":status": "NOT_OK",
            ":comment": errorReturned,
        },
        ReturnValues: "ALL_NEW",
    });

    await dynamo.send(command);

    // check if points are already awarded to user or not

    await dynamo.send(
        new QueryCommand(
            {
                TableName: tableName,
                KeyConditionExpression:
                    "userID = :userID AND quesID = :quesID AND status = :status",
                ExpressionAttributeValues : {
                    ":userID" : body.userID,
                    ":quesID" : body.quesID,
                    ":status" : "OK"
                },
                ConsistentRead: true,
            },
            function (err,data) {
                if(err ) {
                    console.log('Solution Already Scored',' SubmissionID: ',body.submissionID, data)
                    body.weight = 0
                }
            }
        )
    )

    if(body.weight === 0) return

    // push to scoreQ

    const sqs = new AWS.SQS({ apiVersion: "2012-11-05" });
    sqs.sendMessage({
        MessageBody: JSON.stringify(body),
        QueueUrl: getQueueURL(SQS_QUEUE_NAME2),
    }, (err, data) => (err) ? console.log("Error", err) : console.log("Successfully pushed to scoreQ", data));

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