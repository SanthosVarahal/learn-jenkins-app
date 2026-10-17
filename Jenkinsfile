pipeline {
    agent any

    environment {
        NETLIFY_SITE_ID = '09d90942-6051-4013-8893-a438f9b0a7e2'
        NETLIFY_AUTH_TOKEN = credentials('netlify-auth-token')
    }

    stages {
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
                            ls -la
                            node --version
                            npm --version
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
                            image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                            npm install serve
                            node_modules/.bin/serve -s build &
                            sleep 10
                            npx playwright test --reporter=html
                        '''
                    }
                    post {
                        always {
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'HTML Report', reportTitles: '', useWrapperFileDirectly: true])
                        }
                    }
                }
            }
        }

        stage('Deploy staging') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    echo "Deploying the application to staging...."
                    npm install netlify-cli@20.1.1 node-jq
                    node_modules/.bin/netlify --version 
                    echo "Deploying to Netlify... Site ID: $NETLIFY_SITE_ID"
                    node_modules/.bin/netlify status 
                    node_modules/.bin/netlify deploy --dir=build --json > deploy_output.json
                    node_modules/.bin/jq -r '.deploy_url' deploy_output.json                 
                '''
                script {
                    env.STAGING_URL = sh(script: "node_modules/.bin/jq -r '.deploy_url' deploy_output.json", returnStdout: true)
                }
            }
        }
        stage('Post-Staging Tests') {
            agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                    reuseNode true
                }
            }
            environment {
                NETLIFY_STAGING_URL =  "${env.STAGING_URL}"
            }

            steps {
                sh '''
                    echo "Running post-staging tests..."
                    npx playwright test --reporter=html
                '''
            }
           
            post {
                always {
                    publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'staging-playwright-report', reportFiles: 'index.html', reportName: 'Post-Staging HTML Report', reportTitles: '', useWrapperFileDirectly: true])
                }
            }
        }

        stage('approve deployment to production') {
            steps {
                timeout(time: 1, unit: 'MINUTES') {
                    input message: 'Approve deployment to production?', ok: 'Deploy'
                }
            }
        }

        stage('Deploy') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    echo "Deploying the application..."
                    npm install netlify-cli@20.1.1
                    node_modules/.bin/netlify --version 
                    echo "Deploying to Netlify... Site ID: $NETLIFY_SITE_ID"
                    node_modules/.bin/netlify status 
                    node_modules/.bin/netlify deploy --dir=build --prod                  
                '''
            }
        }
        stage('Post-Deployment Tests') {
            agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                    reuseNode true
                }
            }
            
            environment {
                //NETLIFY_SITE_URL = sh(script: "node_modules/.bin/netlify status | grep 'Website URL' | awk '{print \$3}'", returnStdout: true).trim()
                NETLIFY_SITE_URL = "https://resonant-sfogliatella-d94b86.netlify.app"

            steps {
                sh '''
                    echo "Running post-deployment tests..."
                    npx playwright test --reporter=html
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

}