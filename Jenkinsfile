
pipeline {
    agent any

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
    }

    post {
        success {
            echo 'Build and ECR image publishing completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check the Jenkins Console Output.'
        }
        always {
            echo 'Pipeline execution finished.'
        }
    }
}

