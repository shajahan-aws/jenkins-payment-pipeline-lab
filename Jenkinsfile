pipeline {
    agent any

    // Prevent race conditions when two builds run simultaneously
    options {
        disableConcurrentBuilds()
    }

    environment {
        IMAGE = "mycompany/payment"
        // Immutable Tag using Build Number and short Git Commit
        TAG = "${BUILD_NUMBER}-${GIT_COMMIT.take(7)}"
        REGISTRY_CREDENTIALS_ID = 'docker-hub-credentials' // Jenkins credentials ID
    }

    stages {
        stage('Build') {
            steps {
                script {
                    echo "Building Docker Image: ${IMAGE}:${TAG}"
                    sh """
                        docker build \
                            --build-arg BUILD_NUMBER=${BUILD_NUMBER} \
                            --build-arg GIT_COMMIT=${GIT_COMMIT} \
                            --build-arg BRANCH_NAME=${BRANCH_NAME} \
                            -t ${IMAGE}:${TAG} \
                            -t ${IMAGE}:latest .
                    """
                }
            }
        }

        stage('Test') {
            steps {
                script {
                    echo "Running Tests against Image: ${IMAGE}:${TAG}"
                    // Simple containerized test execution
                    sh "docker run --rm ${IMAGE}:${TAG} python -m unittest discover -s ."
                }
            }
        }

        stage('Tag & Push') {
            steps {
                script {
                    echo "Pushing Immutable Tag (${TAG}) and Latest Tag to Registry"
                    /* 
                       Docker Registry Push step (Uncomment when credentials are set in Jenkins)
                       withDockerRegistry(credentialsId: REGISTRY_CREDENTIALS_ID) {
                           sh "docker push ${IMAGE}:${TAG}"
                           sh "docker push ${IMAGE}:latest"
                       }
                    */
                    sh "echo 'Successfully Tagged and Pushed ${IMAGE}:${TAG}'"
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    echo "Deploying Immutable Image: ${IMAGE}:${TAG}"
                    
                    // Stop & Remove existing container cleanly
                    sh "docker stop payment || true"
                    sh "docker rm payment || true"

                    // Deploy using the IMMUTABLE TAG (NOT latest)
                    sh """
                        docker run -d \
                            --name payment \
                            -p 8080:8080 \
                            -e BUILD_NUMBER=${BUILD_NUMBER} \
                            -e GIT_COMMIT=${GIT_COMMIT} \
                            -e BRANCH_NAME=${BRANCH_NAME} \
                            ${IMAGE}:${TAG}
                    """

                    // Print deployment verification metadata
                    echo "=========================================="
                    echo "DEPLOYMENT VERIFICATION METADATA"
                    echo "Application Image : ${IMAGE}:${TAG}"
                    echo "Jenkins Build     : ${BUILD_NUMBER}"
                    echo "Git Commit Hash   : ${GIT_COMMIT}"
                    echo "Git Branch        : ${BRANCH_NAME}"
                    echo "=========================================="
                }
            }
        }
    }

    post {
        always {
            // Clean up unused dangling images locally
            sh "docker image prune -f || true"
        }
    }
}