# Deploy Your Code on a Docker Container Using Jenkins on AWS

## 1. Project Overview

This project demonstrates an automated CI/CD pipeline for deploying a React-based Kanban Dashboard application using Docker, Jenkins, and Amazon Web Services (AWS).

The pipeline integrates GitHub with Jenkins to automatically build, containerize, publish, and deploy application updates to an AWS EC2 instance.

The objective is to minimize manual deployment activities and ensure reliable application delivery.

## 2. Project Architecture

**CI/CD Workflow:**

GitHub → GitHub Webhook → Jenkins → Docker Build → Amazon ECR → AWS EC2 → Running Application

### Workflow

1. Developer pushes code to the GitHub repository.
2. GitHub webhook notifies Jenkins.
3. Jenkins automatically starts the pipeline.
4. Jenkins checks out the source code.
5. Application dependencies are installed and the production build is generated.
6. Docker builds a production image.
7. Docker image is tagged with a unique Jenkins build number.
8. Image is pushed to Amazon ECR.
9. Jenkins deploys the new image to the EC2 instance.
10. Application health checks are performed.
11. If deployment fails, Jenkins attempts to restore the previous container.

## 3. Technologies Used

- AWS EC2 – Application and Jenkins hosting
- AWS IAM – Instance role and permissions
- Amazon ECR – Private Docker image registry
- Docker – Application containerization
- Jenkins – CI/CD automation
- GitHub – Source code management
- GitHub Webhooks – Automatic pipeline triggering
- Ubuntu – EC2 operating system
- React, TypeScript and Vite – Frontend application
- Nginx – Production web server

## 4. AWS Infrastructure

**Region:** Asia Pacific (Mumbai) – ap-south-1

**Services:**
- Amazon EC2 Ubuntu instance
- AWS IAM instance role: EC2-ECR-Kanban-Access
- Amazon ECR repository: kanban-dashboard
- Docker and Jenkins installed on EC2

### Security Group Rules

| Port |      Purpose     |              Access                |
|------|------------------|------------------------------------|
|  22  |        SSH       | My IP                              |
| 8080 |      Jenkins     | My IP and GitHub webhook IP ranges |
|  80  | Application HTTP | Public                             |

GitHub webhook IP ranges are configured as restricted inbound rules for Jenkins.

## 5. Docker Implementation

The application uses a multi-stage Dockerfile.

### Security and Optimization

- Node.js Alpine image for the build stage.
- Nginx unprivileged image for the production stage.
- Only production build files are copied into the final image.
- Application runs as a non-root user (UID 101).
- Docker HEALTHCHECK monitors application availability.
- `.dockerignore` excludes unnecessary files and environment secrets.
- Container resource limits are configured.

### Container Configuration

- Internal application port: 8080
- EC2 application port: 80
- Memory limit: 512 MB
- CPU limit: 1 core
- Restart policy: unless-stopped

## 6. Amazon ECR

Private ECR repository:

`710280692093.dkr.ecr.ap-south-1.amazonaws.com/kanban-dashboard`

Images are tagged using Jenkins build numbers:

- build-1
- build-2
- build-3

This provides versioned image publishing instead of relying only on the `latest` tag.

EC2 accesses ECR using an attached IAM instance role rather than hardcoded AWS access keys.

## 7. Jenkins Pipeline

Jenkins pipeline job:

`kanban-dashboard-pipeline`

### Pipeline Stages

1. Checkout – Retrieves source code from GitHub.
2. Build Application – Installs dependencies and builds React.
3. Build Docker Image – Creates the production Docker image.
4. Login to Amazon ECR – Authenticates with the registry.
5. Push Image to ECR – Publishes the versioned image.
6. Deploy to EC2 – Replaces the running application container.
7. Health Check – Verifies Docker health and HTTP response.
8. Rollback – Attempts to restore the previous container if deployment fails.

The pipeline uses Jenkins build numbers to generate unique Docker image tags.

## 8. GitHub Webhook Automation

GitHub webhook integration enables automatic Jenkins pipeline execution.

**Configuration:**
- GitHub repository: https://github.com/Athil00/kanban-dashboard
- Jenkins job: kanban-dashboard-pipeline
- Trigger: GitHub push event
- Webhook endpoint: `/github-webhook/`
- Shared secret configured in Jenkins and GitHub.

When code is pushed to the main branch, GitHub sends a webhook notification to Jenkins, which automatically starts the pipeline.

## 9. Deployment and Validation

The production application is deployed on EC2 using Docker.

**Application URL:** http://13.235.67.29

### Validation Commands

Check running containers:

```bash
sudo docker ps
```

Check container health:

```bash
sudo docker inspect kanban-app \
  --format '{{.State.Status}} | {{.State.Health.Status}}'
```

Check application response:

```bash
curl -I http://localhost
```

Expected HTTP response:

`HTTP/1.1 200 OK`

## 10. Rollback Strategy

The Jenkins deployment stage preserves the previous container before starting the new version.

If the new container fails its health checks, the pipeline attempts to remove the failed container and restore the previous container.

This supports recovery from failed deployments, although the current port-switching approach may cause a brief interruption.

## 11. Project Results

The following have been implemented and verified:

- React application successfully containerized.
- Multi-stage Docker build completed.
- Non-root production container configured.
- Docker health check verified.
- Amazon ECR image publishing successful.
- Jenkins pipeline successfully executed.
- Automated EC2 deployment successful.
- Application returned HTTP 200.
- GitHub webhook successfully triggered Jenkins automatically.
- Automatic deployment verified with Jenkins build-3.
- Rollback logic included in the deployment pipeline.

## 12. Repository

GitHub: https://github.com/Athil00/kanban-dashboard

---

**Project:** Deploy Your Code on a Docker Container Using Jenkins on AWS

**Cloud Region:** AWS Mumbai (ap-south-1)

**Deployment:** Docker + Jenkins + Amazon ECR + EC2
