#!/bin/bash

# Variables
AWS_REGION="us-east-1"
ECR_REPO_NAME="my-app-repo"
ECS_CLUSTER_NAME="my-app-cluster"
ECS_TASK_DEFINITION_NAME="my-app-task"
ECS_SERVICE_NAME="my-app-service"
DOCKER_IMAGE_NAME="my-app-image"

# Step 1: Build the Docker image
docker build -t $DOCKER_IMAGE_NAME .

# Step 2: Authenticate Docker to the Amazon ECR registry
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $(aws sts get-caller-identity --query 'Account' --output text).dkr.ecr.$AWS_REGION.amazonaws.com

# Step 3: Create an ECR repository (if it doesn't exist)
aws ecr describe-repositories --repository-names $ECR_REPO_NAME --region $AWS_REGION || \
aws ecr create-repository --repository-name $ECR_REPO_NAME --region $AWS_REGION

# Step 4: Tag the Docker image for ECR
ECR_URI=$(aws sts get-caller-identity --query 'Account' --output text).dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME
docker tag $DOCKER_IMAGE_NAME:latest $ECR_URI:latest

# Step 5: Push the Docker image to ECR
docker push $ECR_URI:latest

# Step 6: Create an ECS cluster (if it doesn't exist)
aws ecs describe-clusters --clusters $ECS_CLUSTER_NAME --region $AWS_REGION || \
aws ecs create-cluster --cluster-name $ECS_CLUSTER_NAME --region $AWS_REGION

# Step 7: Create an ECS task definition
cat <<EOF > ecs-task-def.json
{
  "family": "$ECS_TASK_DEFINITION_NAME",
  "networkMode": "awsvpc",
  "executionRoleArn": "arn:aws:iam::$(aws sts get-caller-identity --query 'Account' --output text):role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "$DOCKER_IMAGE_NAME",
      "image": "$ECR_URI:latest",
      "essential": true,
      "memory": 512,
      "cpu": 256,
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80
        }
      ]
    }
  ],
  "requiresCompatibilities": [
    "FARGATE"
  ],
  "cpu": "256",
  "memory": "512"
}
EOF

aws ecs register-task-definition --cli-input-json file://ecs-task-def.json --region $AWS_REGION

# Step 8: Create an ECS service to run the task
aws ecs create-service \
  --cluster $ECS_CLUSTER_NAME \
  --service-name $ECS_SERVICE_NAME \
  --task-definition $ECS_TASK_DEFINITION_NAME \
  --desired-count 1 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-12345678],securityGroups=[sg-12345678],assignPublicIp=ENABLED}" \
  --region $AWS_REGION

