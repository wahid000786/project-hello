# project-hello-world
## Steps to build docker container locally :
"docker build -t my-web-app ." this command builds the Dockerfile and 
"docker run -p 8080:80 my-web-app"
this command will run the docker container at the port no. localhost:8080.

## How the CI/CD pipeline works and how to trigger it.
The CI/CD pipeline is triggered by mentioning the code of :
on: 
  push:
    branches:
      -main
so any push happens in the main branch will be triggered automatically.

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    -name: Checkout code
     uses: actions/..

    -name: Build Docker iamges
     run: |
       docker build -t my-web-app .
       docker run -p 8080:80 my-web-app

here we are mentioning the jobs we want to perform and the job is build with the next procedure as steps and building the docker image named "my-web-app ." then run it on the by default port no. localhost:8080

## How to run the deployment script or commands to deploy the container to the chosen cloud service.
1. Build the docker image 
2. Authenticate the Docker to the Amazon ECR registry:
   "aws ecr get-login-password | docker login --username AWS -- password-stdin <ecr-registry-name>
3. Create and ECR repository(if it has not been created)
4. Tag the docker image for ECR
5. Push the Docker image to ECR
6. Create an ECS task definition directly from the shell script using AWS CLI.
7. Register the AWS ECS task definition " aws ecs register-task-definition --cli-input-json file://ecs-task-def.json'
8. Then created an ECS service to run the task.
9. Ensuring that the IAM role 'ecsTaskExecutionRole' exists, and has the necessory permissions. 
    

