pipeline {
    agent any

    environment {
        EC2_HOST = 'REPLACE_ME_WITH_YOUR_EC2_PUBLIC_IP'   // 🟨 Replace with your EC2 IP or DNS
        EC2_USER = 'REPLACE_ME_WITH_YOUR_EC2_USER'        // 🟨 Usually 'ubuntu' or 'ec2-user'
        DEPLOY_DIR = '~/app/inventory'                    // 🟨 Change if you want a different path
    }

    parameters {
        string(name: 'BRANCH', defaultValue: 'dev', description: 'Git branch to deploy')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout([$class: 'GitSCM',
                    branches: [[name: "*/${params.BRANCH}"]],
                    userRemoteConfigs: [[url: 'https://github.com/ramyasree1505/inventory_management_devOps.git']]
                ])
            }
        }

        stage('Prepare Environment Files') {
            steps {
                sh '''
                  mkdir -p deploy/env
                  cat > deploy/env/.env <<'EOF'
NODE_ENV=production
MONGO_URI=REPLACE_ME_WITH_YOUR_MONGO_URI          # 🟨 Replace with your MongoDB connection string
STRIPE_SECRET_KEY=REPLACE_ME_WITH_YOUR_STRIPE_KEY # 🟨 Replace with your Stripe secret key
RESEND_API_KEY=REPLACE_ME_WITH_YOUR_RESEND_KEY    # 🟨 Replace with your Resend API key
CLOUDINARY_URL=REPLACE_ME_WITH_YOUR_CLOUDINARY_URL# 🟨 Replace with your Cloudinary URL
EOF
                '''
            }
        }

        stage('Deploy to EC2') {
            steps {
                sshagent (credentials: ['REPLACE_ME_WITH_YOUR_JENKINS_SSH_CREDENTIAL_ID']) { // 🟨 Replace with Jenkins SSH credential ID
                    sh '''
                      HOST="${EC2_HOST}"
                      USER="${EC2_USER}"

                      # Create directory on EC2
                      ssh -o StrictHostKeyChecking=no "$USER@$HOST" "mkdir -p ${DEPLOY_DIR}"

                      # Sync repo files
                      rsync -az --delete --exclude '.git' --exclude 'node_modules' ./ "$USER@$HOST:${DEPLOY_DIR}/"

                      # Sync env files
                      rsync -az deploy/env/ "$USER@$HOST:${DEPLOY_DIR}/"

                      # Build and run containers on EC2
                      ssh -o StrictHostKeyChecking=no "$USER@$HOST" "
                        cd ${DEPLOY_DIR}
                        docker compose down || true
                        docker compose build
                        docker compose up -d
                      "
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Deployment failed.'
        }
    }
}
