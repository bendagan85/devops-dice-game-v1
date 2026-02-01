# 🎲 DevOps Dice Game: End-to-End GitOps Deployment

![Build Status](https://img.shields.io/badge/build-passing-brightgreen)
![Terraform](https://img.shields.io/badge/infrastructure-Terraform-purple)
![Kubernetes](https://img.shields.io/badge/orchestration-EKS-blue)
![Jenkins](https://img.shields.io/badge/cicd-Jenkins-red)

A comprehensive DevOps project demonstrating a fully automated **GitOps workflow**. This repository contains the Infrastructure as Code (IaC) to provision an AWS EKS cluster, alongside a robust CI/CD implementation using Jenkins with Dynamic Kubernetes Agents.

The system features auto-scaling, secure HTTPS ingress, live configuration injection, and self-healing capabilities.

---

## 🏗️ Architecture & Infrastructure

The entire infrastructure is provisioned using **Terraform** on AWS. The setup includes a VPC, Security Groups, and an EKS Cluster hosting both the application and the CI/CD server.

### Infrastructure Provisioning
* **Provider:** AWS
* **Orchestrator:** Elastic Kubernetes Service (EKS)
* **IaC Tool:** Terraform

![Gemini Generated Image](Gemini_Generated_Image_ne1nvune1nvune1n.png)

### Cluster Status
Successful provisioning of EKS nodes ready for workload scheduling:

![EKS Nodes](project6images/get-nodes.png)

---

## 🚀 CI/CD Pipelines (Jenkins)

The project utilizes **Jenkins** running within the cluster. A key feature of this implementation is the use of **Dynamic Build Agents**. Instead of static executors, Jenkins spins up ephemeral Pods for each build, ensuring resource efficiency and clean build environments.

**System Health Dashboard:**
![Jenkins Dashboard](project6images/jenkinsworks.png)

**Dynamic Agent Provisioning (Proof of Concept):**
![Agent Pod Creation](project6images/agentpod.png)

### 1. CI/CD Pipeline (Build & Deploy)
* **Trigger:** SCM (Git) changes / Pull Requests.
* **Stages:** Build Docker Image → Push to Private Hub → Helm Upgrade.
* **Outcome:** Automatic deployment to the `devops` namespace.

![Deployment Success](project6images/deployedtoeks+successmessage.png)

### 2. Operational Pipeline: Scaling Management
Allows DevOps engineers to control the number of replicas and update image tags dynamically via the Jenkins UI.

**Parameter Input:**
![Scaling Parameters](project6images/buildwithparameters2.png)

**Result:** Scaling to 3 Replicas successfully applied:
![3 Replicas Running](project6images/3replicascauseofpipeline.png)

### 3. Operational Pipeline: Live Configuration Injection
A specialized pipeline designed to inject configuration files or secrets into **running pods** without requiring a restart or redeployment.

**Parameter Input (Secret Content):**
![Injection Parameters](project6images/buildwithparametersinject.png)

**Verification:** Validating the file existence inside the pod:
![Injection Verification](project6images/injectworks.png)

---

## 🔒 Security & Networking

The application is exposed via an **Nginx Ingress Controller**, enforcing HTTPS termination and routing traffic to internal ClusterIP services. Direct external access to pods is blocked.

* **Ingress Controller:** Nginx
* **Termination:** TLS/SSL (Self-Signed for demo purposes)
* **Service Type:** ClusterIP (Internal only)

**Secure HTTPS Access (Browser):**
![HTTPS UI](project6images/https-ui.png)

**Ingress & LoadBalancer Correlation:**
![Ingress IP Verification](project6images/sameipasingressui.png)

---

## 📈 Observability & Auto-Scaling (HPA)

The system implements **Horizontal Pod Autoscaling (HPA)** based on CPU utilization. A Metrics Server collects real-time data, allowing Kubernetes to automatically scale pods up during high load and scale down during idle times.

* **Metric:** CPU Utilization
* **Threshold:** 50%
* **Max Replicas:** 10

**HPA Status (Metrics Active):**
![HPA Status](project6images/hpa.png)

---

## 🔌 API Usage

The application exposes a REST API for game interaction.

**Endpoint:** `GET /roll`
**Response:** JSON format containing the dice roll result.

![REST API Request](project6images/restapi.png)

---

## 🛠️ Prerequisites & Installation

To deploy this project from scratch:

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/your-user/devops-dice-game.git](https://github.com/your-user/devops-dice-game.git)
    ```
2.  **Provision Infrastructure:**
    ```bash
    cd terraform
    terraform init
    terraform apply
    ```
3.  **Deploy Jenkins:**
    ```bash
    helm install jenkins jenkins/jenkins -n jenkins --create-namespace
    ```
4.  **Configure Pipelines:** Import the `Jenkinsfile`s located in the `pipelines/` directory.


**Tech Stack:** AWS, Terraform, Kubernetes, Docker, Jenkins, Python (Flask), Nginx.
