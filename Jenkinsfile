pipeline {
    agent any

    tools {
        nodejs 'NodeJS'
    }

    stages {

        stage('Checkout') {
            steps {
               checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId: 'GitCreds', url: 'https://github.com/Subhash-Rokkala/React-E-Mart.git']])
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm install'
            }
        }

        stage('Build Project') {
            steps {
                sh 'CI=false npm run build || echo "No build step, skipping..."'
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker build -t E-mart .'
            }
        }

        stage('Docker Run') {
            steps {
                sh 'docker rm -f E-mart-container || true'
                sh 'docker run -d -p 8085:80 --name E-mart-container E-mart'
            }
        }
    }
}
