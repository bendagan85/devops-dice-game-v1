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
  # 1. קונטיינר שמריץ את מנוע הדוקר (השרת)
  - name: dind
    image: docker:24-dind
    securityContext:
      privileged: true
    env:
      - name: DOCKER_TLS_CERTDIR
        value: ""
      
  # 2. קונטיינר שמריץ את הפקודות (הלקוח)
  - name: docker
    image: docker:24-cli
    command:
    - cat
    tty: true
    env:
      - name: DOCKER_HOST
        value: tcp://localhost:2375

  # 3. קונטיינר לניהול קוברנטיס
  - name: kubectl
    image: bitnami/kubectl:latest
    command:
    - cat
    tty: true
"""
        }
    }
    
    environment {
        // החלף לשם המשתמש שלך ב-DockerHub
        DOCKERHUB_USER = 'bendagan85' 
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
                        // בדיקה שאנחנו מצליחים לדבר עם הדוקר
                        sh 'docker info'
                        
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
                            sh "docker login -u $USER -p $PASS"
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
                        // יצירת Namespace אם לא קיים
                        sh "kubectl create namespace devops --dry-run=client -o yaml | kubectl apply -f -"
                        
                        // עדכון גרסת האימג' בקובץ ה-Deployment
                        sh "sed -i 's|PLACEHOLDER_IMAGE|${DOCKER_IMAGE}|g' k8s/deployment.yaml"
                        
                        // הפעלת הקבצים
                        sh "kubectl apply -f k8s/deployment.yaml"
                        sh "kubectl apply -f k8s/service.yaml"
                    }
                }
            }
        }
    }
}