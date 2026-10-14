pipeline {
    agent any

    environment {
        AWS_REGION = 'ap-south-1'
        ECR_REGISTRY = '288743750282.dkr.ecr.ap-south-1.amazonaws.com'
        ECR_REPOSITORY = 'devops-app'
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Checking out DemoWebApp from GitHub...'
                git branch: 'main',
                    url: 'https://github.com/Anuradha122118/DemoWebApp.git'
            }
        }

        stage('Maven Build') {
            steps {
                echo 'Building application with Maven...'
                sh 'mvn clean package'
            }
        }

        stage('Docker Build') {
            steps {
                echo "Building Docker image: ${ECR_REPOSITORY}:${IMAGE_TAG}"
                sh '''
                    docker build -t ${ECR_REPOSITORY}:${IMAGE_TAG} .
                '''
            }
        }

        stage('ECR Login') {
            steps {
                echo 'Logging in to Amazon ECR...'
                sh '''
                    aws ecr get-login-password --region ${AWS_REGION} | \
                    docker login --username AWS --password-stdin ${ECR_REGISTRY}
                '''
            }
        }

        stage('Push to ECR') {
            steps {
                echo 'Tagging and pushing Docker image to ECR...'
                sh '''
                    docker tag ${ECR_REPOSITORY}:${IMAGE_TAG} \
                    ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}

                    docker push \
                    ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}
                '''
            }
        }

        stage('Refresh ECR Secret') {
            steps {
                echo 'Refreshing Kubernetes ECR pull secret...'
                sh '''
                    kubectl create secret docker-registry ecr-secret \
                      --docker-server=${ECR_REGISTRY} \
                      --docker-username=AWS \
                      --docker-password="$(aws ecr get-login-password --region ${AWS_REGION})" \
                      --dry-run=client -o yaml | kubectl apply -f -
                '''
            }
        }

        stage('Deploy with Helm') {
            steps {
                echo "Deploying image ${IMAGE_TAG} with Helm..."
                sh '''
                    /snap/bin/helm upgrade --install devops-app helm/devops-app \
                      --namespace default \
                      --set image.tag=${IMAGE_TAG}

                    kubectl rollout status deployment/devops-app
                    /snap/bin/helm status devops-app --namespace default
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                echo 'Verifying deployed image...'
                sh '''
                    echo "Deployed image:"
                    kubectl get deployment devops-app \
                      -o=jsonpath='{.spec.template.spec.containers[0].image}'
                    echo

                    echo "Pods:"
                    kubectl get pods -o wide
                '''
            }
        }
    }

    post {
        success {
            echo 'CI/CD pipeline completed successfully!'
        }

        failure {
            echo 'CI/CD pipeline failed. Check the stage logs above.'
        }
    }
}
