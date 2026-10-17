pipeline {
    agent any

    stages {
        /*
        stage('Build') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    ls -la
                    node --version
                    npm --version
                    npm ci 
                    npm run build
                    ls -la
                '''
            }
        }*/
        stage('Test') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    test -f build/index.html || { echo "Build failed: build/index.html not found"; exit 1; }
                    ls -la
                    node --version
                    npm --version
                    npm test 
                '''
            }
        }
        stage('E2E Tests') {
            agent {
                docker {
                    image 'cypress/included:12.17.1'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    test -f build/index.html || { echo "Build failed: build/index.html not found"; exit 1; }
                    ls -la
                    node --version
                    npm --version
                    npm run e2e 
                '''
            }
        }
    }
    post {
        always {
            junit 'test-results/junit.xml'
        }
    }
}