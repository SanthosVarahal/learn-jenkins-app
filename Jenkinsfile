pipeline {
    agent any

    environment {
        NETLIFY_SITE_ID = '09d90942-6051-4013-8893-a438f9b0a7e2'
        NETLIFY_AUTH_TOKEN = credentials('netlify-auth-token')
        REACT_APP_VERSION = "1.0.$BUILD_ID"
    }

    stages {
        stage('DOcker') {
            steps {
                sh '''
                   docker build -t my-playwright-image .
                '''
            }
        }

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
        }

        stage('Test') {
            parallel {
                stage('Unit Tests') {
                    agent {
                        docker {
                            image 'node:18-alpine'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                            test -f build/index.html || { echo "Build failed: build/index.html not found"; exit 1; }
                            npm test 
                        '''
                    }
                    post {
                        always {
                            junit 'jest-results/junit.xml'
                        }
                    }
                }
                stage('E2E Tests') {
                    agent {
                        docker {
                            image 'my-playwright-image'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                            serve -s build &
                            sleep 10
                            npx playwright test --reporter=html
                        '''
                    }
                    post {
                        always {
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Local E2E', reportTitles: '', useWrapperFileDirectly: true])
                        }
                    }
                }  
            }
        }

        stage('Deploy staging') {
            agent {
                docker {
                    image 'my-playwright-image'
                    reuseNode true
                }
            }

            environment {
                CI_ENVIRONMENT_URL = 'STAGING_URL_TO_BE_SET'
            }

            steps {
                sh '''
                    netlify --version
                    echo "Deploying to staging. Site ID: $NETLIFY_SITE_ID"
                    netlify status
                    netlify deploy --dir=build --json > deploy-output.json
                    CI_ENVIRONMENT_URL=$(jq -r '.deploy_url' deploy-output.json)
                    npx playwright test  --reporter=html             
                '''
            }

            post {
                always {
                    publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'staging-playwright-report', reportFiles: 'index.html', reportName: 'Post-Staging HTML Report', reportTitles: '', useWrapperFileDirectly: true])
                }
            }
        }

        stage('Deploy Production') {
            agent {
                docker {
                    image 'my-playwright-image'
                    reuseNode true
                }
            }

            environment {
                CI_ENVIRONMENT_URL = 'https://resonant-sfogliatella-d94b86.netlify.app/'
            }

            steps {
                sh '''
                    node --version
                    netlify --version
                    echo "Deploying to production. Site ID: $NETLIFY_SITE_ID"
                    netlify status
                    netlify deploy --dir=build --prod
                    npx playwright test  --reporter=html
                '''
            }
           
            post {
                always {
                    publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'Prod-playwright-report', reportFiles: 'index.html', reportName: 'Post-Deployment HTML Report', reportTitles: '', useWrapperFileDirectly: true])
                }
            }    
        }   
    }    
}