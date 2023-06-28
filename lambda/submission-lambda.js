import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import {
    DynamoDBDocumentClient,
    QueryCommand
} from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({});

const dynamo = DynamoDBDocumentClient.from(client);

const tableName = "submission";

export const handler = async (event, context) => {
    let body;
    let statusCode = 200;
    const headers = {
        "Content-Type": "application/json",
    };

    try {
        switch (event.routeKey) {
            case "GET /submission/{?submissionID&?userID}":
                body = await dynamo.send(
                    new QueryCommand({
                        TableName: tableName,
                        KeyConditionExpression:
                            "submissionID = :submissionID AND userID = :userID",
                        ExpressionAttributeValues: {
                            ":submissionID" : event.pathParameters.submissionID,
                            ":userID" : event.pathParameters.userID,
                        },
                        ConsistentRead: true,
                    })
                );
                body = body.Item;
                break;
            case "GET /submissions/{?contestID&?userID}":
                body = await dynamo.send(
                    new QueryCommand({
                        TableName: tableName,
                        KeyConditionExpression:
                            "contestID = :contestID AND userID = :userID",
                        ExpressionAttributeValues: {
                            ":contestID" : event.pathParameters.contestID,
                            ":userID" : event.pathParameters.userID,
                        },
                        ConsistentRead: true,
                    })
                );
                body = body.Items;
                break;
            default:
                throw new Error(`Unsupported route: "${event.routeKey}"`);
        }
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
