# codex

codex is a scalable, robust, cloud based distributed system for hosting coding contest on a large scale. Imagine, a coding contest such as Google CodeJam or Facebook HackerCup is happening, there are millions of requests for viewing one or more problem statements, submitting a solution to a problem, viewing scoreboard, fetching a previously submitted solution, etc. Handling such large number of requests becomes a challenge. Codex is an approach to this challenge. Codex ensures increased flexibility, reliability, and scalability. The cloud provider used is [AWS](https://aws.amazon.com/) . Built completely using serverless stack this ensures the use of FaaS(Function as a Service) approach. [Terraform](https://www.terraform.io/) has been used as IaaC(Infrastructure as a Code) tool for defining, provisioning and managing infrastructure. The architecture is designed to be asynchronous for handling more number of requests in a given time. 


## codex architecture

![image of codex-architecture](/codex-architecture.png)



## Features provided

1. user authentication and authorization
1. submitting solution to a problem
1. evaluation of submissions
1. fetching previously submitted solution or solutions by a user
1. fetching scoreboard 
1. fetching all and any particular problem


## Workflow

### For viewing problems 
The client request goes to Route53 and gets redirected to cloudfront, where cloudfront fetches questions from s3 contest bucket, and user can view problems. No authentication required for this part.

### For authentication 
The client reaches for registered URL and gets redirected by route53 to Cognito, where login credentials are authenticated by cognito. The details for credentials verification are stored in s3 user bucket accessible through cognito. 

### For submitting a solution
User authentication required. The request reaches API gateway where the path parameters and request fields are validated. If authorization is permissible, the request reaches submit lambda and after checking for valid fields in request, it is queued in SQS submission queue and a 202 submission received response is returned to client. A record is made in DynamoDB submission database of the request queued. The queued request is then dequeued by evaluate lambda, where it is sent to vendor API for processing and evaluating the submission. The correctness and status of the submission received is updated in DynamoDB submission database and then the request is queued in SQS submit queue, this request is then dequeued from worker lambda, which depending upon the correctness of submission as evaluated by evaluate lambda, modifies the DynamoDB score database. The reason behind providing multiple lambda and queues based architecture is to provide asynchronous nature to system.

### For viewing a submission
User authentication required. The request reaches API gateway where the path parameters and request fields are validated. If authorization is permissible, the request reaches submission lambda and after checking for valid fields in request, the submission lambda returns for a particular submission or many submissions. This information is retrieved from DynamoDB submission database. 

### For viewing scoreboard
User authentication required. The request reaches API gateway where the path parameters and request fields are validated. If authorization is permissible, the request reaches score lambda and after checking for valid fields in request, the score lambda returns rank and score of user. This information is retrieved from DynamoDB submission database. 


## Main components

### API gateway
API gateway is used for forwarding score, submission and submit requests to their respective lambdas based on pre-defined setup paths while deployment. It validates the request body and triggers the correct lambda while also monitoring, maintaining and securing the endpoints.

### Cloudfront 
Cloudfront is used for fetching problem statements by users. It is used to speed up distribution of static and dynamic web content to users through a worldwide network of data centers.

### Route53 
Route53 is used for reaching all routes for submitting solutions, fetching problems, scoreboard updates, submission statuses, etc. It is used because it is highly available and scalable Domain Name System (DNS) web service which is used to perform three main functions in any combination: domain registration, DNS routing, and health checking.

### Cognito  
Cognito is used for authenticating and authorizing user requests. Each submission, submit and score request goes through cognito, after this the requests reach to API gateway. It is used because it is an identity platform for web and mobile apps. It’s a user directory, an authentication server, and an authorization service for OAuth 2.0 access tokens and credentials. With Cognito, authentication and authorization of users from the built-in user directory, from  enterprise directory, and from consumer identity providers can be easily done.

### Submission lambda 
Submission lambda is used for fetching one or more previously submitted submissions from submission database. The lambdas used throughout the project run code on high availability compute infrastructure without any need for resource administration, provisioning or management including server and operating system maintenance, capacity provisioning and automatic scaling, and logging.

### Score lambda 
Score lambda is used for fetching scoreboard updates from score database.

### Submit lambda 
Submit lambda is used for submitting a solution to a problem. When user submits a solution,   { 202 : solution queued } response is returned to user. An entry is made in submission database about the new submission. 

### Worker lambda 
Worker lambda is used to update scoreboard based on correctness of submission. It updates score database, note that if points for a particular problem has already been awarded to user, then no score updation occurs.

### Evaluate lambda  
Evaluate lambda is used to process a submission from queue and then evaluate its correctness with vendor API integration, and based on correctness of solution, it sets or resets the fields for score updation which will be later done by worker lambda. The status of submission is updated in submission database, along with detailed comments on errors occurred if submission code is incorrect.

### Score database 
Score database is used to store score of individual users in a contest. We have used NoSQL database service for fast and predictable performance with scalability. DynamoDB is used to offload burden of hardware provisioning, setup and configuration, replication, software patching, cluster scaling. and operating a distributed database.

### Submission database
Submission database is used to store submission related information for each submission made. The fields include status of submission, error after evaluation, submission code, submission language, submission time, userID, quesID, etc.

### Score queue 
Score queue is used for queueing submissions which have been evaluated and are ready to update scoreboard. We have used SQS to integrate and decouple distributed software system and components. This helps make our system asynchronous.

### Submission queue 
Submission queue is used for queueing submissions which are submitted by user and not yet evaluated.

### Contest bucket 
Contest bucket is used to store contest related details, including details of problem statement which can be fetched by cloudfront. S3 is used for scalability, security and enhancing performance. 

### User bucket 
User bucket is used to store details of users which is used for user request authorization and authentication by cognito. 


## Tech Stack
- Terraform
- AWS
- Javscript
- NodeJS

