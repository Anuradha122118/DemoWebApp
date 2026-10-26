
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
                sh 'mvn clean verify'
            }
        }

        stage('SonarQube Cloud Analysis') {
            steps {
                echo 'Running SonarQube Cloud analysis...'
                withCredentials([
                    string(credentialsId: 'sonar-token',
                           variable: 'SONAR_TOKEN')
                ]) {
                    sh '''
                        mvn org.sonarsource.scanner.maven:sonar-maven-plugin:sonar \
                          -Dsonar.projectKey=Anuradha122118_DemoWebApp \
                          -Dsonar.organization=anuradha122118 \
                          -Dsonar.host.url=https://sonarcloud.io \
                          -Dsonar.token="$SONAR_TOKEN"
                    '''
                }
            }
        }

        stage('Trivy Filesystem Scan') {
            steps {
                echo 'Scanning source code and configuration files...'
                sh '''
                    trivy --config "" fs \
                      --scanners vuln,misconfig,secret \
                      --exit-code 0 \
                      --skip-dirs .git \
                      --skip-dirs .m2 \
                      .
                '''
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

        stage('Trivy Image Scan') {
            steps {
                echo "Scanning Docker image ${ECR_REPOSITORY}:${IMAGE_TAG}..."
                sh '''
                    trivy --config "" image \
                      --severity HIGH,CRITICAL \
                      --exit-code 0 \
                      ${ECR_REPOSITORY}:${IMAGE_TAG}
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

        stage('Production Approval') {
            steps {
                timeout(time: 15, unit: 'MINUTES') {
                    input(
                        message: "Approve deployment of DemoWebApp build ${BUILD_NUMBER}, image tag ${IMAGE_TAG}?",
                        ok: 'Approve Deployment'
                    )
                }
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
                      --set image.tag=${IMAGE_TAG} \
                      --force-conflicts

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


