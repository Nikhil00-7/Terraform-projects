pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key')       // Your Jenkins Access Key ID credential ID
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')       // Your Jenkins Secret Key credential ID
        TF_IN_AUTOMATION      = "true"
        PATHL = "/usr/local/bin:${env.PATH}"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main' ,url: 'https://github.com/Nikhil00-7/Terraform-projects.git'
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan -out=tfplan'
            }
        }

        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -auto-approve tfplan'
            }
        }

    }

    post {
        success {
            echo 'Infrastructure deployed successfully!'
        }
        failure {
            echo 'Infrastructure deployment failed!'
        }
    }
}
