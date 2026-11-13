pipeline {
    agent any

    options {
        disableConcurrentBuilds()
    }

    environment {
        AWS_REGION = 'ap-south-1'
        AWS_ACCOUNT_ID = '710280692093'
        ECR_REPOSITORY = 'kanban-dashboard'
        ECR_REGISTRY = '710280692093.dkr.ecr.ap-south-1.amazonaws.com'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                echo 'Source code checked out successfully'
            }
        }

        stage('Build Application') {
            steps {
                sh 'npm ci'
                sh 'npm run build'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    env.IMAGE_TAG = "build-${env.BUILD_NUMBER}"
                    env.IMAGE_URI = "${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"
                }

                sh 'docker build -t "$IMAGE_URI" .'
            }
        }

        stage('Login to Amazon ECR') {
            steps {
                sh '''
                    aws ecr get-login-password --region "$AWS_REGION" |
                    docker login --username AWS --password-stdin "$ECR_REGISTRY"
                '''
            }
        }

        stage('Push Image to ECR') {
            steps {
                sh 'docker push "$IMAGE_URI"'
            }
        }

        stage('Deploy to EC2') {
            steps {
                sh '''#!/bin/bash
                    set -Eeuo pipefail

                    NEW_CONTAINER="kanban-app"
                    OLD_CONTAINER="kanban-app-previous"
                    OLD_MOVED=0

                    rollback() {
                        STATUS=$?

                        if [ "$STATUS" -ne 0 ] && [ "$OLD_MOVED" -eq 1 ]; then
                            echo "Deployment failed. Restoring previous container..."

                            docker rm -f "$NEW_CONTAINER" || true

                            if docker inspect "$OLD_CONTAINER" >/dev/null 2>&1; then
                                docker rename "$OLD_CONTAINER" "$NEW_CONTAINER"
                                docker start "$NEW_CONTAINER" || true
                            elif docker inspect "$NEW_CONTAINER" >/dev/null 2>&1; then
                                docker start "$NEW_CONTAINER" || true
                            fi
                        fi
                    }

                    trap rollback EXIT

                    echo "Pulling new image: $IMAGE_URI"
                    docker pull "$IMAGE_URI"

                    if ! docker inspect "$NEW_CONTAINER" >/dev/null 2>&1; then
                        echo "Existing application container not found."
                        exit 1
                    fi

                    docker rm -f "$OLD_CONTAINER" 2>/dev/null || true

                    echo "Preserving the existing application..."
                    OLD_MOVED=1
                    docker stop "$NEW_CONTAINER"
                    docker rename "$NEW_CONTAINER" "$OLD_CONTAINER"

                    echo "Starting new application..."
                    docker run -d \
                        --name "$NEW_CONTAINER" \
                        --restart unless-stopped \
                        -p 80:8080 \
                        --memory=512m \
                        --cpus=1.0 \
                        "$IMAGE_URI"

                    echo "Waiting for application health..."
                    HEALTH="starting"

                    for attempt in $(seq 1 30); do
                        HEALTH=$(docker inspect \
                            --format '{{.State.Health.Status}}' \
                            "$NEW_CONTAINER")

                        echo "Health check $attempt/30: $HEALTH"

                        if [ "$HEALTH" = "healthy" ]; then
                            break
                        fi

                        if [ "$HEALTH" = "unhealthy" ]; then
                            echo "New container is unhealthy."
                            exit 1
                        fi

                        sleep 2
                    done

                    if [ "$HEALTH" != "healthy" ]; then
                        echo "Health check timed out."
                        exit 1
                    fi

                    echo "Checking application HTTP response..."
                    curl --fail --silent --show-error \
                        http://127.0.0.1/ > /dev/null

                    echo "Application deployment verified!"

                    trap - EXIT
                    docker rm -f "$OLD_CONTAINER" || true

                    echo "Previous container cleaned up."
                '''
            }
        }
    }

    post {
        success {
            echo 'Build, ECR publishing and deployment completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check Console Output and rollback status.'
        }
        always {
            echo 'Pipeline execution finished.'
        }
    }
}
