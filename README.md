# Deploy Your Code on a Docker Container Using Jenkins on AWS

## 1. Project Overview

This project demonstrates how to deploy a React-based Kanban Dashboard application using **Docker, Jenkins, Amazon ECR, and AWS EC2**.

A Jenkins CI/CD pipeline is configured to automatically build the application, create a Docker image, push the image to Amazon ECR, and deploy the application on an AWS EC2 instance.

GitHub Webhooks are used to trigger the Jenkins pipeline automatically whenever code is pushed to the repository.

## 2. Project Architecture

```text
Developer
   |
   v
GitHub Repository
   |
   v
GitHub Webhook
   |
   v
Jenkins on AWS EC2
   |
   v
Build React Application
   |
   v
Build Docker Image
   |
   v
Push Image to Amazon ECR
   |
   v
Deploy Container on AWS EC2
   |
   v
Health Check
   |
   v
Running Application
```

## 3. Technologies Used

| Technology | Purpose |
|---|---|
| AWS EC2 | Hosts Jenkins and the application |
| AWS IAM | Provides secure AWS permissions |
| Amazon ECR | Stores Docker images |
| Docker | Builds and runs containers |
| Jenkins | Automates the CI/CD pipeline |
| GitHub | Stores application source code |
| GitHub Webhooks | Automatically trigger Jenkins |
| Node.js and npm | Build the React application |
| Nginx | Serves the production application |
| Ubuntu | EC2 operating system |

## 4. AWS Infrastructure

- Created an Ubuntu EC2 instance in the AWS Mumbai region (`ap-south-1`).
- Configured a Security Group with the required inbound rules.

| Port | Service | Source |
|---|---|---|
| 22 | SSH | My IP |
| 8080 | Jenkins | My IP and GitHub webhook IP ranges |
| 80 | Application | Anywhere (IPv4) |

- Installed Docker and Jenkins on the EC2 instance.
- Attached an IAM role to EC2 to access Amazon ECR without storing AWS access keys.

## 5. Docker Implementation

Created a multi-stage Dockerfile to build and serve the React application.

**Docker implementation includes:**

- Node.js Alpine image for building the application.
- Nginx unprivileged Alpine image for serving the production files.
- Runs Nginx as a non-root user (UID 101).
- Configured a Docker health check.
- Added `.dockerignore` to exclude unnecessary files from the Docker build context.
- Added `.gitignore` to prevent unnecessary and sensitive files from being committed.

The production container uses port `8080` internally and maps it to port `80` on the EC2 instance.

Container resource limits:

- Memory: 512 MB
- CPU: 1.0
- Restart policy: `unless-stopped`

## 6. Amazon ECR Configuration

Created an Amazon Elastic Container Registry (ECR) repository to store Docker images.

**Repository details:**

- Repository name: `kanban-dashboard`
- AWS Region: `ap-south-1`
- Image tags used include `build-1`, `build-2`, and `build-3`.
- Image scanning on push was enabled.

**ECR Repository URI:**

```text
710280692093.dkr.ecr.ap-south-1.amazonaws.com/kanban-dashboard
```

Configured an IAM role and policy to allow the EC2 instance to authenticate with ECR and push and pull Docker images.

## 7. Jenkins CI/CD Pipeline

Created a Jenkins pipeline job named:

```text
kanban-dashboard-pipeline
```

The pipeline is defined in the `Jenkinsfile` stored in the GitHub repository.

**Pipeline stages:**

1. **Checkout** – Retrieves source code from GitHub.
2. **Build Application** – Installs dependencies and builds the React application.
3. **Build Docker Image** – Creates a Docker image.
4. **ECR Login** – Authenticates with Amazon ECR.
5. **Push Image** – Pushes the tagged image to ECR.
6. **Deploy** – Pulls and deploys the image on EC2.
7. **Health Check** – Checks whether the deployed application is healthy.
8. **Rollback Handling** – Includes logic to attempt recovery using the previous container if deployment fails.

## 8. GitHub Webhook Automation

Configured a GitHub Webhook to connect the repository with Jenkins.

- Enabled **GitHub hook trigger for GITScm polling** in Jenkins.
- Configured the webhook URL in GitHub.
- Added a shared secret for webhook authentication.
- Selected Push events.
- Updated the EC2 Security Group to allow the required GitHub webhook IP ranges on port `8080`.

Tested the webhook using a Git push and verified that Jenkins automatically started a new pipeline build.

## 9. Deployment and Validation

The application was deployed on the EC2 instance using a Docker container.

**Container details:**

- Container name: `kanban-app`
- Internal port: `8080`
- Host port: `80`
- Restart policy: `unless-stopped`

**Validation commands:**

Check running containers:

```bash
sudo docker ps
```

Check container health:

```bash
sudo docker inspect kanban-app \
  --format '{{.Config.Image}} | {{.State.Status}} | {{.State.Health.Status}}'
```

Check application response:

```bash
curl -I http://localhost
```

The application returned an HTTP `200 OK` response, and the deployed container was verified as running and healthy.

The application can be accessed using:

```text
http://EC2-PUBLIC-IP
```

Replace `EC2-PUBLIC-IP` with the current public IP address of the EC2 instance.

A temporary test container was also used to verify an image pulled from ECR on port `8081`. After testing, the temporary container was removed.

## 10. Rollback Strategy

Rollback handling is included in the Jenkins pipeline.

If a deployment fails, the pipeline contains logic to attempt to restore the previous application container.

**Note:** Rollback failure simulation and recovery testing were not performed as part of this project.

Zero-downtime deployment was also not implemented.

## 11. Project Results

The project successfully demonstrates:

- Hosting Jenkins and the application on AWS EC2.
- Building a React application.
- Creating a production-ready Docker image.
- Pushing Docker images to Amazon ECR.
- Automating deployment through a Jenkins pipeline.
- Triggering Jenkins builds through GitHub Webhooks.
- Verifying container health and application availability.
- Enabling ECR image scanning on push.

The deployed application was verified as running and healthy, and the application returned HTTP `200 OK`.

## 12. Repository

**GitHub Repository:**

https://github.com/Athil00/kanban-dashboard.git

**Main project files:**

| File | Purpose |
|---|---|
| `Dockerfile` | Builds the production Docker image |
| `.dockerignore` | Excludes unnecessary files from Docker builds |
| `.gitignore` | Excludes unnecessary and sensitive files from Git |
| `Jenkinsfile` | Defines the CI/CD pipeline |
| `README.md` | Project documentation |

---

**Project Title:** Deploy Your Code on a Docker Container Using Jenkins on AWS

**Status:** Core CI/CD deployment successfully completed.
