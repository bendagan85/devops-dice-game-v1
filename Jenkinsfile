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
    # הסרנו את kubectl מכאן כדי לחסוך זיכרון
"""
        }
    }
    
    environment {
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
                        // המתנה לדוקר
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
                            sh 'echo $PASS | docker login -u $USER --password-stdin'
                            sh "docker push ${DOCKER_IMAGE}"
                        }
                    }
                }
            }
        }

        stage('Deploy to K8s') {
            steps {
                container('docker') { // משתמשים בקונטיינר הקיים
                    script {
                        echo 'Installing kubectl inside docker container...'
                        // התקנה מהירה של kubectl ו-curl
                        sh "apk add --no-cache curl"
                        sh "curl -LO https://dl.k8s.io/release/v1.31.0/bin/linux/amd64/kubectl"
                        sh "chmod +x kubectl"
                        sh "mv kubectl /usr/local/bin/"
                        
                        echo 'Deploying to Kubernetes...'
                        sh "kubectl create namespace devops --dry-run=client -o yaml | kubectl apply -f -"
                        
                        // עדכון הגרסה בקובץ
                        sh "sed -i 's|PLACEHOLDER_IMAGE|${DOCKER_IMAGE}|g' k8s/deployment.yaml"
                        
                        // הפעלה
                        sh "kubectl apply -f k8s/deployment.yaml"
                        sh "kubectl apply -f k8s/service.yaml"
                    }
                }
            }
        }
    }
}