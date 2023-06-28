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

    const fileName = this.requestBody.fileName;
    const foldername = 'problem-'+body.contestID+'-'+body.quesID ;
    const params = {
        Bucket: 's3-bucket-problems',
        Key: `${foldername}/${fileName}`,
    };
    const s3 = new S3();
    const { s3ResponseBody } = await s3.getObject(params).promise()

    let score = s3ResponseBody.score;
    let res = await dynamo.send(
        new QueryCommand({
            TableName: tableName,
            KeyConditionExpression:
                "userID = :userID",
            ExpressionAttributeValues: {
                ":userID" : body.userID
            },
            ConsistentRead: true,
        })
    );
    res = res.Item;
    score += res.score;
    await dynamo.send(
        new UpdateCommand({
            TableName: tableName,
            Key: {
                userID: body.userID,
            },
            UpdateExpression: "set score = :score",
            ExpressionAttributeValues: {
                ":score": score,
            },
            ReturnValues: "ALL_NEW",
        })
    )
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