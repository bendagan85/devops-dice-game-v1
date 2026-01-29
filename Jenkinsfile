pipeline {
    agent {
        kubernetes {
            // הגדרת הבונוס: פוד דינמי שנוצר רק לזמן הריצה
            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    some-label: some-label-value
spec:
  containers:
  - name: docker
    image: docker:latest
    command:
    - cat
    tty: true
    volumeMounts:
    - mountPath: /var/run/docker.sock
      name: docker-sock
  - name: kubectl
    image: bitnami/kubectl:latest
    command:
    - cat
    tty: true
  volumes:
  - name: docker-sock
    hostPath:
      path: /var/run/docker.sock
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