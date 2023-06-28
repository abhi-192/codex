import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import {
    DynamoDBDocumentClient,
    QueryCommand
} from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({});

const dynamo = DynamoDBDocumentClient.from(client);

const tableName = "score";

export const handler = async (event, context) => {
    let body;
    let statusCode = 200;
    const headers = {
        "Content-Type": "application/json",
    };

    try {
        switch (event.routeKey) {
            case "GET /score/{contestID}":
                body = await dynamo.send(
                    new QueryCommand({
                        TableName: tableName,
                        KeyConditionExpression:
                            "contestID = :contestID",
                        ExpressionAttributeValues : {
                            ":contestID" : event.pathParameters.contestID,
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
