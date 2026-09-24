# AWS ECS Fargate Platform

Production-style deployment of a containerized web application on AWS using Docker, Amazon ECS Fargate, Terraform, Amazon ECR, Application Load Balancer, AWS Certificate Manager, Route 53, and GitHub Actions.

This project demonstrates the progression from a locally running application to an automated AWS deployment using containerization, Infrastructure as Code, CI/CD, security scanning, and cloud-native services.

## Architecture

                         Internet
                            │
                            ▼
                     Amazon Route 53
                            │
                            ▼
                 AWS Certificate Manager
                       HTTPS :443
                            │
                            ▼
                Application Load Balancer
                     Public Subnets
                            │
                         HTTP :80
                            │
                            ▼
                   ECS Fargate Service
                    Private Subnets
                            │
                            ▼
                    Threat Composer
                   Docker Container
                            │
                            ▼
                       Amazon ECR

## Project Overview

This project takes the [Threat Composer](https://github.com/CoderCo-Learning/ecs-assignment) application and builds a production-style AWS deployment around it.

The goal is to demonstrate practical cloud and DevOps engineering skills including:

- Containerization with Docker
- AWS ECS Fargate
- Amazon ECR
- Application Load Balancer
- HTTPS with AWS Certificate Manager
- Route 53 DNS
- Terraform Infrastructure as Code
- GitHub Actions CI/CD
- AWS IAM and least-privilege access
- CloudWatch logging and monitoring
- Container security scanning
- Automated health checks

The infrastructure will initially be deployed and validated manually, then recreated using Terraform and automated through GitHub Actions.

## Technology Stack

### Application

- React
- TypeScript
- Node.js
- Yarn

### Containerization

- Docker
- Multi-stage Docker builds
- Nginx
- Non-root container execution
- `/health` endpoint

### AWS

- Amazon ECS Fargate
- Amazon ECR
- Application Load Balancer
- Amazon VPC
- Route 53
- AWS Certificate Manager
- IAM
- CloudWatch
- CloudWatch Logs

### Infrastructure as Code

- Terraform

### CI/CD

- GitHub Actions
- GitHub OIDC
- Automated Docker builds
- SHA-based image tagging
- Terraform plan/apply
- Automated deployment validation

### Security

- IAM least privilege
- AWS OIDC authentication
- Trivy container scanning
- Checkov Terraform scanning
- Secrets management
- No long-lived AWS access keys in GitHub

## Repository Structure

    aws-ecs-fargate-platform/
    │
    ├── app/
    │   ├── src/
    │   ├── public/
    │   ├── config/
    │   ├── package.json
    │   └── yarn.lock
    │
    ├── infra/
    │   ├── modules/
    │   ├── environments/
    │   └── ...
    │
    ├── .github/
    │   └── workflows/
    │
    ├── Dockerfile
    ├── nginx.conf
    ├── .dockerignore
    ├── .gitignore
    └── README.md

## Local Development

### Prerequisites

- Git
- Node.js
- Yarn
- Docker
- AWS CLI
- Terraform

### Clone the repository

    git clone https://github.com/mdirie3/aws-ecs-fargate-platform.git
    cd aws-ecs-fargate-platform

### Install application dependencies

    cd app
    yarn install

### Start the application

    yarn start

The application will be available at:

    http://localhost:3000

## Docker

The application is packaged using a multi-stage Docker build.

The build stage compiles the React application, while the runtime stage uses a lightweight Nginx container to serve the production application.

### Build the image

From the repository root:

    docker build -t threat-composer:local .

### Run the container

    docker run --rm -p 8080:80 threat-composer:local

The application will be available at:

    http://localhost:8080

### Test the application

    curl http://localhost:8080/

### Test the health endpoint

    curl http://localhost:8080/health

Expected response:

    {
      "status": "ok"
    }

The `/health` endpoint is used by the Application Load Balancer and ECS to determine whether the application is healthy.

## AWS Deployment

The AWS deployment is implemented in multiple stages.

### Phase 1 — Containerization

The application is first prepared for production container deployment.

Tasks include:

- Create a multi-stage Dockerfile
- Build the React application
- Serve the production build using Nginx
- Add a `/health` endpoint
- Run the container locally
- Validate the application and health endpoint
- Run container security scanning

### Phase 2 — Amazon ECR

Amazon Elastic Container Registry is used to store application images.

The deployment process will:

1. Build the Docker image
2. Tag the image using the Git commit SHA
3. Authenticate to Amazon ECR
4. Push the image to ECR

Example image:

    <account-id>.dkr.ecr.<region>.amazonaws.com/threat-composer:<commit-sha>

Using commit SHA tags provides traceability between source code and deployed containers.

### Phase 3 — ECS Fargate

The application is deployed using Amazon ECS with AWS Fargate.

The ECS configuration includes:

- ECS cluster
- Fargate task definition
- ECS service
- Private subnets
- Security groups
- IAM execution role
- IAM task role
- CloudWatch log group
- ECR container image

The ECS tasks do not require public IP addresses.

Traffic is received through the Application Load Balancer.

### Phase 4 — Application Load Balancer

An Application Load Balancer provides the public entry point to the application.

The ALB configuration includes:

- Public subnets
- Security group
- Target group
- HTTP listener
- HTTPS listener
- Health checks

The ALB forwards application traffic to ECS tasks on port `80`.

Health checks use:

    GET /health

Expected response:

    {
      "status": "ok"
    }

HTTP traffic can be redirected to HTTPS.

### Phase 5 — HTTPS and DNS

AWS Certificate Manager provides the TLS certificate for the application.

Route 53 provides DNS resolution.

The final architecture will provide access through a custom domain:

    https://app.example.com

Traffic flow:

    User
     │
     ▼
    Route 53
     │
     ▼
    ALB :443
     │
     ▼
    ECS Fargate
     │
     ▼
    Application

## Terraform Infrastructure

After validating the AWS architecture manually, the infrastructure will be recreated using Terraform.

Terraform will manage resources including:

- VPC
- Public subnets
- Private subnets
- Internet Gateway
- NAT Gateway
- Route tables
- Security groups
- Amazon ECR
- ECS cluster
- ECS task definition
- ECS service
- IAM roles and policies
- Application Load Balancer
- Target group
- ALB listeners
- ACM certificate
- Route 53 records
- CloudWatch log groups

The goal is to make the environment reproducible rather than dependent on manually configured AWS resources.

## Terraform Structure

The infrastructure will follow a modular structure similar to:

    infra/
    │
    ├── environments/
    │   └── dev/
    │       ├── main.tf
    │       ├── variables.tf
    │       ├── outputs.tf
    │       └── terraform.tfvars.example
    │
    ├── modules/
    │   ├── networking/
    │   ├── security/
    │   ├── ecr/
    │   ├── ecs/
    │   ├── alb/
    │   ├── acm/
    │   └── route53/
    │
    └── README.md

Terraform state will not be committed to Git.

Files such as:

    terraform.tfstate
    terraform.tfstate.*
    .terraform/
    *.tfvars

are excluded through `.gitignore`.

## CI/CD

GitHub Actions will automate the application deployment process.

The pipeline will follow:

    Git Push
       │
       ▼
    Build & Test
       │
       ▼
    Security Scanning
       │
       ├── Trivy
       └── Checkov
       │
       ▼
    Docker Build
       │
       ▼
    Push Image → Amazon ECR
       │
       ▼
    Terraform Init
       │
       ▼
    Terraform Plan
       │
       ▼
    Terraform Apply
       │
       ▼
    ECS Deployment
       │
       ▼
    Health Check

## GitHub Actions Authentication

GitHub Actions will authenticate to AWS using OpenID Connect (OIDC).

Long-lived AWS access keys will not be stored in GitHub repository secrets.

The workflow will assume an AWS IAM role with permissions required for the deployment.

The intended authentication flow is:

    GitHub Actions
          │
          ▼
    GitHub OIDC
          │
          ▼
    AWS IAM Role
          │
          ▼
    AWS Resources

This reduces the need to manage long-lived AWS credentials in the CI/CD system.

## Security

Security controls are incorporated throughout the architecture.

### AWS Network Security

ECS tasks run in private subnets without public IP addresses.

Security groups restrict traffic between components.

Example:

    Internet
       │
       ▼
    ALB Security Group
       │
       │ TCP 80/443
       ▼
    ECS Security Group
       │
       │ TCP 80
       ▼
    ECS Task

The ECS security group allows application traffic from the ALB security group rather than allowing unrestricted inbound traffic from the internet.

### IAM

IAM follows the principle of least privilege where practical.

Separate IAM roles are used for:

- ECS task execution
- ECS application tasks
- GitHub Actions deployment

### Container Security

The container build will include:

- Multi-stage builds
- Minimal runtime image
- Non-root execution
- `.dockerignore`
- Trivy vulnerability scanning
- No secrets baked into the image

### Infrastructure Security

Terraform configuration will be scanned with Checkov to identify common AWS and IaC security issues.

## Monitoring and Logging

Application logs will be sent to Amazon CloudWatch Logs.

The deployment will use ECS and ALB health checks to determine application availability.

The initial monitoring architecture includes:

    ECS Fargate
         │
         ▼
    CloudWatch Logs

and:

    Application Load Balancer
         │
         ▼
       /health
         │
         ▼
    ECS Task Health

Future monitoring improvements may include:

- CloudWatch alarms
- ECS CPU utilization alarms
- ECS memory utilization alarms
- ALB 4xx/5xx alarms
- Deployment failure alerts
- Application metrics

## Deployment Strategy

ECS will use rolling deployments to gradually replace existing application tasks.

Docker images will be tagged using the Git commit SHA rather than relying exclusively on the `latest` tag.

Example:

    threat-composer:a83f91c

This creates traceability between the source code and deployed container:

    Git Commit
        │
        ▼
    Docker Image
        │
        ▼
    Amazon ECR
        │
        ▼
    ECS Task Definition
        │
        ▼
    ECS Service
        │
        ▼
    Production Application

## Infrastructure Workflow

The project demonstrates a progression from manual AWS configuration to Infrastructure as Code.

### Step 1 — Local Application

    React Application
          │
          ▼
    Local Development

### Step 2 — Docker

    React Application
          │
          ▼
    Docker Image
          │
          ▼
    Local Container

### Step 3 — AWS ClickOps

    Docker Image
          │
          ▼
    ECR
          │
          ▼
    ECS Fargate
          │
          ▼
    ALB
          │
          ▼
    HTTPS

### Step 4 — Terraform

    Terraform
        │
        ├── VPC
        ├── IAM
        ├── ECR
        ├── ECS
        ├── ALB
        ├── ACM
        └── Route 53

### Step 5 — CI/CD

    GitHub
       │
       ▼
    GitHub Actions
       │
       ├── Test
       ├── Scan
       ├── Build
       ├── Push
       └── Deploy
       │
       ▼
    AWS

## Project Goals

This project is designed to demonstrate practical experience with:

- AWS cloud infrastructure
- Containerized workloads
- ECS Fargate
- Docker
- Terraform
- Infrastructure as Code
- AWS networking
- Application Load Balancing
- IAM
- CI/CD
- GitHub Actions
- OIDC authentication
- CloudWatch
- Container security
- Infrastructure security
- Production deployment practices

## Lessons Demonstrated

Key engineering concepts demonstrated throughout the project include:

- Building production-oriented Docker images
- Designing AWS network boundaries
- Running containers without public IP addresses
- Configuring ALB health checks
- Managing infrastructure through Terraform
- Understanding Terraform state and drift
- Creating reproducible infrastructure
- Implementing CI/CD automation
- Using immutable container image tags
- Using OIDC instead of long-lived cloud credentials
- Scanning containers for vulnerabilities
- Scanning Terraform configurations for security issues
- Troubleshooting application and infrastructure deployments
- Connecting source control, CI/CD, containers, and AWS infrastructure

## Future Improvements

Potential future enhancements include:

- [ ] Terraform remote state using Amazon S3
- [ ] Terraform state locking
- [ ] Development and production environments
- [ ] ECS Service Auto Scaling
- [ ] CloudWatch alarms
- [ ] Automated rollback
- [ ] Blue/green deployments
- [ ] AWS WAF
- [ ] CloudFront
- [ ] Prometheus/Grafana metrics
- [ ] Dependency vulnerability scanning
- [ ] Automated infrastructure drift detection
- [ ] Additional integration tests
- [ ] Deployment notifications

## Application

This project uses the Threat Composer application as the workload being containerized and deployed.

The DevOps infrastructure, containerization, AWS architecture, Terraform configuration, and CI/CD implementation are maintained in this repository.

## Author

**Mohamed Dirie**

Cloud / DevOps Engineer

AWS | Terraform | Docker | Kubernetes | ECS | CI/CD | Infrastructure as Code