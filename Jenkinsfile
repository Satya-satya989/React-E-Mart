pipeline {
    agent any

    tools {
        nodejs 'NodeJS'
    }
    environment {
    SONARQUBE_ENV = 'sq'
    }

    stages {

        stage('Checkout') {
            steps {
            checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId: 'gitcred', url: 'https://github.com/Satya-satya989/React-E-Mart.git']])
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
        stage('SonarQube Analysis') {
        steps {
            withSonarQubeEnv("${SONARQUBE_ENV}") {
                sh '''
                npx sonar-scanner \
                -Dsonar.projectKey=e-mart \
                -Dsonar.sources=src
              '''
            }
         }
      }
       stage('Quality Gate') {
    steps {
        timeout(time: 5, unit: 'MINUTES') {
            waitForQualityGate abortPipeline: false
        }
    }
}

       stage('Upload Artifact to Nexus') {
    steps {
        sh '''
        npm install
        CI=false npm run build
        zip -r dist.zip dist/

        curl -u admin:admin123 \
        --upload-file dist.zip \
        http://35.174.111.33:8081/repository/react-artifacts/dist.zip
        '''
    }
}      
        stage('Docker Build') {
            steps {
                sh 'docker build -t e-mart .'
            }
        }

        stage('Docker Push') {
    steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-cred', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
            sh '''
            echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin

            docker tag e-mart $DOCKER_USER/e-mart:latest

            docker push $DOCKER_USER/e-mart:latest
            '''
        }
    }
}
        

        stage('Docker Run') {
        steps {
            sh 'docker stop e-mart-container || true'
            sh 'docker rm e-mart-container || true'
            sh 'docker run -d -p 8086:80 --name e-mart-container e-mart'
       }
    }
        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    sh '''
                    kubectl apply -f k8s/Deployment.yml
                    kubectl apply -f k8s/loadBalancerService.yml
                    '''
                }
            }
        }
    }
}
