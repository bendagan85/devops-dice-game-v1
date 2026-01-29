pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: jenkins-agent
spec:
  containers:
  - name: dind
    image: docker:24-dind
    securityContext:
      privileged: true
    env:
      - name: DOCKER_TLS_CERTDIR
        value: ""
      
  - name: docker
    image: docker:24-cli
    command:
    - cat
    tty: true
    env:
      - name: DOCKER_HOST
        value: tcp://localhost:2375

  - name: kubectl
    image: bitnami/kubectl:latest
    command:
    - cat
    tty: true
"""
        }
    }
    
    environment {
        // ודא שזה שם המשתמש הנכון (בלי ה-85 אם המשתמש הוא bendagan)
        DOCKERHUB_USER = 'bendagan' 
        APP_NAME = 'devops-dice-game'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        DOCKER_IMAGE = "${DOCKERHUB_USER}/${APP_NAME}:${IMAGE_TAG}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                container('docker') {
                    script {
                        // --- התיקון: המתנה עד שהדוקר עולה ---
                        sh '''
                          echo "Waiting for Docker daemon..."
                          while ! docker info > /dev/null 2>&1; do
                            echo "Docker not ready yet..."
                            sleep 3
                          done
                          echo "Docker is ready!"
                        '''
                        
                        echo 'Building Docker Image...'
                        sh "docker build -t ${DOCKER_IMAGE} ."
                    }
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                container('docker') {
                    script {
                        echo 'Pushing to DockerHub...'
                        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                            // שימוש ב---password-stdin לאבטחה טובה יותר
                            sh 'echo $PASS | docker login -u $USER --password-stdin'
                            sh "docker push ${DOCKER_IMAGE}"
                        }
                    }
                }
            }
        }

        stage('Deploy to K8s') {
            steps {
                container('kubectl') {
                    script {
                        echo 'Deploying to Kubernetes...'
                        sh "kubectl create namespace devops --dry-run=client -o yaml | kubectl apply -f -"
                        
                        // שימוש ב-sed עם מפריד אחר למקרה של תווים מיוחדים
                        sh "sed -i 's|PLACEHOLDER_IMAGE|${DOCKER_IMAGE}|g' k8s/deployment.yaml"
                        
                        sh "kubectl apply -f k8s/deployment.yaml"
                        sh "kubectl apply -f k8s/service.yaml"
                    }
                }
            }
        }
    }
}